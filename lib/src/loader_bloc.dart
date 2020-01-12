import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_loader/src/loader_message.dart';
import 'package:stream_loader/src/loader_state.dart';
import 'package:stream_loader/src/partial_state_change.dart';
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';

class LoaderBloc<Content> {
  /// Outputs
  final ValueStream<LoaderState<Content>> state$;
  final Stream<LoaderMessage> message$;

  /// Inputs
  final void Function() fetch;
  final Future<void> Function() refresh;

  /// Dispose
  final void Function() _dispose;

  void dispose() => _dispose();

  LoaderBloc._(
    this._dispose, {
    @required this.state$,
    @required this.fetch,
    @required this.refresh,
    @required this.message$,
  });

  factory LoaderBloc({
    @required Stream<Content> Function() loaderFunction,
    Stream<Content> Function() refresherFunction,
    Content initial,
    bool enableLogger = true,
  }) {
    assert(loaderFunction != null, 'loaderFunction cannot be null');
    assert(enableLogger != null, 'enableLogger cannot be null');
    refresherFunction ??= loaderFunction;

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
          .startWith(LoaderPartialStateChange.fetchLoading())
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

    final initialState = LoaderState<Content>.initial(initial);
    final state$ = Rx.merge([fetchChanges, refreshChanges])
        .scan(_reduce, initialState)
        .publishValueSeededDistinct(seedValue: initialState);

    final subscriptions = [
      state$.connect(),
      if (enableLogger) ...[
        state$.listen((state) => print('[LOADER BLOC] state=$state')),
        messageS.listen((message) => print('[LOADER BLOC] message=$message')),
      ],
    ];

    return LoaderBloc._(
      DisposeBag([...subscriptions, ...controllers]).dispose,
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

  /// Reducer
  static LoaderState<Content> _reduce<Content>(
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
