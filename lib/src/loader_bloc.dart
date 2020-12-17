import 'dart:async';

import 'package:disposebag/disposebag.dart' show DisposeBag;
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart'
    show DistinctValueConnectableExtensions, DistinctValueStream;
import 'package:meta/meta.dart' show required, visibleForTesting;
import 'package:rxdart/rxdart.dart'
    show
        PublishSubject,
        Rx,
        SwitchMapExtension,
        ExhaustMapExtension,
        DoExtensions,
        OnErrorExtensions,
        ScanExtension,
        StartWithExtension;

import 'loader_message.dart';
import 'loader_state.dart';
import 'partial_state_change.dart';

/// BLoC that handles loading and refreshing data
class LoaderBloc<Content> {
  static const _tag = '« stream_loader »';

  /// View state stream
  final DistinctValueStream<LoaderState<Content>> state$;

  /// Message stream
  final Stream<LoaderMessage<Content>> message$;

  /// Call this function fetch data
  final void Function() fetch;

  /// Call this function to refresh data
  final Future<void> Function() refresh;

  /// Clean up resources
  final Future<void> Function() dispose;

  LoaderBloc._({
    @required this.dispose,
    @required this.state$,
    @required this.fetch,
    @required this.refresh,
    @required this.message$,
  });

  /// Construct a [LoaderBloc]
  /// The [loaderFunction] is a function return a stream of [Content]s (must be not null).
  /// It's called when [fetch] is called
  ///
  /// The [refresherFunction] is a function return a stream of [Content]s (can be null).
  /// It's called when [refresh] is called
  /// When it is null, is will equal to a function that returns a empty stream
  ///
  /// The [initialContent] is used to create initial view state (can be null)
  factory LoaderBloc({
    @required Stream<Content> Function() loaderFunction,
    Stream<Content> Function() refresherFunction,
    Content initialContent,
    void Function(String) logger,
  }) {
    assert(loaderFunction != null, 'loaderFunction cannot be null');
    refresherFunction ??= () => Stream.empty();

    // ignore_for_file: close_sinks
    /// Controllers
    final fetchS = StreamController<void>();
    final refreshS = StreamController<Completer<void>>();
    final messageS = PublishSubject<LoaderMessage<Content>>();
    final controllers = <StreamController<dynamic>>[fetchS, refreshS, messageS];

    /// Input actions to state
    final fetchChanges = fetchS.stream.switchMap(
      (_) => Rx.defer(loaderFunction)
          .doOnData(
              (content) => messageS.add(LoaderMessage.fetchSuccess(content)))
          .map<LoaderPartialStateChange<Content>>(
              (content) => LoaderPartialStateChange.fetchSuccess(content))
          .startWith(const LoaderPartialStateChange.fetchLoading())
          .doOnError((e, s) => messageS.add(LoaderMessage.fetchFailure(e, s)))
          .onErrorReturnWith((e) => LoaderPartialStateChange.fetchFailure(e)),
    );
    final refreshChanges = refreshS.stream.exhaustMap(
      (completer) => Rx.defer(refresherFunction)
          .doOnData(
              (content) => messageS.add(LoaderMessage.refreshSuccess(content)))
          .map<LoaderPartialStateChange<Content>>(
              (content) => LoaderPartialStateChange.refreshSuccess(content))
          .doOnError((e, s) => messageS.add(LoaderMessage.refreshFailure(e, s)))
          .onErrorResumeNext(Stream.empty())
          .doOnDone(() => completer.complete()),
    );

    final initialState = LoaderState.initial(content: initialContent);
    final state$ = Rx.merge([fetchChanges, refreshChanges])
        .let((stream) =>
            logger?.let(
                (l) => stream.doOnData((data) => l('$_tag change: $data'))) ??
            stream)
        .scan(reduce, initialState)
        .publishValueDistinct(initialState, sync: true);

    final subscriptions = [
      state$.connect(),
      ...?logger?.let(
        (l) => [
          state$.listen((state) => l('$_tag state: $state')),
          messageS.listen((message) => l('$_tag message: $message')),
        ],
      ),
    ];

    return LoaderBloc._(
      dispose: () => DisposeBag([...subscriptions, ...controllers])
          .dispose()
          .let(
            (future) =>
                logger?.let((l) =>
                    future.then((result) => l('$_tag disposed: $result'))) ??
                future,
          ),
      state$: state$,
      fetch: () => fetchS.add(null),
      refresh: () {
        final completer = Completer<void>();
        refreshS.add(completer);
        return completer.future;
      },
      message$: messageS,
    );
  }

  /// Return new [LoaderState] from old [state] and partial state [change]
  @visibleForTesting
  static LoaderState<Content> reduce<Content>(
    LoaderState<Content> state,
    LoaderPartialStateChange<Content> change,
    int _,
  ) {
    return change.fold(
      onRefreshSuccess: (content) => state.rebuild((b) => b
        ..content = content
        ..error = null),
      onFetchLoading: () => state.rebuild((b) => b
        ..isLoading = true
        ..error = null),
      onFetchFailure: (error) => state.rebuild((b) => b
        ..isLoading = false
        ..error = error),
      onFetchSuccess: (content) => state.rebuild((b) => b
        ..isLoading = false
        ..error = null
        ..content = content),
    );
  }
}

extension _X<T> on T {
  @pragma('vm:prefer-inline')
  R let<R>(R Function(T) block) => block(this);
}
