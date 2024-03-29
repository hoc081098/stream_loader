import 'dart:async';

import 'package:disposebag/disposebag.dart' show DisposeBag;
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:rxdart_ext/rxdart_ext.dart';

import 'loader_message.dart';
import 'loader_state.dart';
import 'partial_state_change.dart';
import 'utils.dart';

// ignore_for_file: close_sinks

/// Describes how a stream of inner streams should be flattened into a stream of values.
enum FlattenStrategy {
  /// uses [FlatMapExtension.flatMap].
  merge,

  /// uses [Stream.asyncExpand].
  concat,

  /// uses [SwitchMapExtension.switchMap].
  latest,

  /// uses [ExhaustMapExtension.exhaustMap].
  first,
}

extension _FlatMapWithStrategy<T> on Stream<T> {
  Stream<R> flatMapWithStrategy<R>(
      FlattenStrategy strategy, Stream<R> Function(T) transform) {
    switch (strategy) {
      case FlattenStrategy.merge:
        return flatMap(transform);
      case FlattenStrategy.concat:
        return asyncExpand(transform);
      case FlattenStrategy.latest:
        return switchMap(transform);
      case FlattenStrategy.first:
        return exhaustMap(transform);
    }
  }
}

/// BLoC that handles loading and refreshing data
class LoaderBloc<Content extends Object> {
  static const _tag = '💧stream_loader💧';

  /// View state stream
  final StateStream<LoaderState<Content>> state$;

  /// Message stream
  final Stream<LoaderMessage<Content>> message$;

  /// Call this function to fetch data
  final void Function() fetch;

  /// Call this function to refresh data
  final Future<void> Function() refresh;

  /// Clean up resources
  Future<void> dispose() => _dispose();
  final Future<void> Function() _dispose;

  LoaderBloc._({
    required Future<void> Function() dispose,
    required this.state$,
    required this.fetch,
    required this.refresh,
    required this.message$,
  }) : _dispose = dispose;

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
    required Stream<Content> Function() loaderFunction,
    Stream<Content> Function()? refresherFunction,
    Content? initialContent,
    void Function(String)? logger,
    FlattenStrategy loaderFlattenStrategy =
        FlattenStrategy.latest, // default is `switchMap`
    FlattenStrategy refreshFlattenStrategy =
        FlattenStrategy.first, // default is `exhaustMap`
  }) {
    refresherFunction ??= () => Stream<Content>.empty();

    /// Controllers
    final fetchS = StreamController<void>();
    final refreshS = StreamController<Completer<void>>();
    final messageS = PublishSubject<LoaderMessage<Content>>();
    final controllers = <StreamController<dynamic>>[fetchS, refreshS, messageS];

    /// Input actions to state
    final fetchChanges = fetchS.stream.flatMapWithStrategy(
      loaderFlattenStrategy,
      (_) => Rx.defer(loaderFunction)
          .doOnData(
              (content) => messageS.add(LoaderMessage.fetchSuccess(content)))
          .map<LoaderPartialStateChange<Content>>(
              (content) => LoaderPartialStateChange.fetchSuccess(content))
          .startWith(const LoaderPartialStateChange.fetchLoading())
          .doOnError((e, s) => messageS.add(LoaderMessage.fetchFailure(e, s)))
          .onErrorReturnWith(
              (e, _) => LoaderPartialStateChange.fetchFailure(e)),
    );
    final refreshChanges = refreshS.stream.flatMapWithStrategy(
      refreshFlattenStrategy,
      (completer) => Rx.defer(refresherFunction!)
          .doOnData(
              (content) => messageS.add(LoaderMessage.refreshSuccess(content)))
          .map<LoaderPartialStateChange<Content>>(
              (content) => LoaderPartialStateChange.refreshSuccess(content))
          .doOnError((e, s) => messageS.add(LoaderMessage.refreshFailure(e, s)))
          .onErrorResumeNext(const Stream.empty())
          .doOnCancel(() => completer.complete()),
    );

    final initialState = LoaderState.initial(content: initialContent);
    final state$ = Rx.merge([fetchChanges, refreshChanges])
        .let((stream) =>
            logger?.let(
                (l) => stream.doOnData((data) => l('$_tag change: $data'))) ??
            stream)
        .scan(reduce, initialState)
        .publishState(initialState);

    final subscriptions = [
      state$.connect(),
      ...?logger?.let(
        (l) => [
          state$.listen((state) => l('$_tag state: $state')),
          messageS.listen((message) => l('$_tag message: $message')),
        ],
      ),
    ];

    late LoaderBloc<Content> bloc;
    bloc = LoaderBloc._(
      dispose: () => DisposeBag(
        [...subscriptions, ...controllers],
        '${bloc.runtimeType}#${bloc.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0')}',
      ).dispose(),
      state$: state$,
      fetch: () => fetchS.add(null),
      refresh: () {
        final completer = Completer<void>.sync();
        refreshS.add(completer);
        return completer.future;
      },
      message$: messageS,
    );
    return bloc;
  }

  /// Return new [LoaderState] from old [state] and partial state [change]
  @visibleForTesting
  static LoaderState<Content> reduce<Content extends Object>(
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
