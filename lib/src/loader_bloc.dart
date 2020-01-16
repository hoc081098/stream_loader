import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_loader/src/loader_message.dart';
import 'package:stream_loader/src/loader_state.dart';
import 'package:stream_loader/src/partial_state_change.dart';
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';

/// BLoC that handles loading and refreshing data
class LoaderBloc<Content> {
  /// View state stream
  final ValueStream<LoaderState<Content>> state$;

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
  ///
  /// The [enableLogger] to used to enable logging state and message stream (must be not null)
  factory LoaderBloc({
    @required Stream<Content> Function() loaderFunction,
    Stream<Content> Function() refresherFunction,
    Content initialContent,
    bool enableLogger = false,
  }) {
    assert(loaderFunction != null, 'loaderFunction cannot be null');
    assert(enableLogger != null, 'enableLogger cannot be null');
    refresherFunction ??= () => Stream.empty();

    // ignore_for_file: close_sinks
    /// Subjects
    final fetchS = PublishSubject<void>();
    final refreshS = PublishSubject<Completer<void>>();
    final messageS = PublishSubject<LoaderMessage<Content>>();
    final controllers = [fetchS, refreshS, messageS];

    /// Input actions to state
    final fetchChanges = fetchS.switchMap(
      (_) => Rx.defer(loaderFunction)
          .doOnData(
              (content) => messageS.add(LoaderMessage.fetchSuccess(content)))
          .map<LoaderPartialStateChange<Content>>(
              (content) => LoaderPartialStateChange.fetchSuccess(content))
          .startWith(const LoaderPartialStateChange.fetchLoading())
          .doOnError((e, s) => messageS.add(LoaderMessage.fetchFailure(e, s)))
          .onErrorReturnWith((e) => LoaderPartialStateChange.fetchFailure(e)),
    );
    final refreshChanges = refreshS.exhaustMap(
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
        .doOnData((data) {
          if (enableLogger) {
            print('[LOADER_BLOC] change=$data');
          }
        })
        .scan(reduce, initialState)
        .publishValueSeededDistinct(seedValue: initialState);

    final subscriptions = [
      state$.connect(),
      if (enableLogger) ...[
        state$.listen((state) => print('[LOADER BLOC] state=$state')),
        messageS.listen((message) => print('[LOADER BLOC] message=$message')),
      ],
    ];

    return LoaderBloc._(
      dispose: DisposeBag([...subscriptions, ...controllers]).dispose,
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
