import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stream_loader/src/loader_bloc.dart';
import 'package:stream_loader/src/loader_message.dart';
import 'package:stream_loader/src/loader_state.dart';

typedef LoaderBuilder<Content> = Widget Function(
    BuildContext context, LoaderState<Content> state, LoaderBloc<Content> bloc);
typedef LoaderMessageHandler<Content> = void Function(
    LoaderMessage<Content> message, LoaderBloc<Content> bloc);

class LoaderWidget<Content> extends StatefulWidget {
  final LoaderBloc<Content> Function() blocProvider;
  final LoaderMessageHandler<Content> messageHandler;
  final LoaderBuilder<Content> builder;

  const LoaderWidget({
    Key key,
    @required this.blocProvider,
    @required this.builder,
    LoaderMessageHandler<Content> messageHandler,
  })  : assert(blocProvider != null),
        assert(builder != null),
        this.messageHandler = messageHandler ?? _emptyMessageHandler,
        super(key: key);

  @override
  _LoaderWidgetState<Content> createState() => _LoaderWidgetState<Content>();

  static void _emptyMessageHandler<T>(
    LoaderMessage<T> message,
    LoaderBloc<T> bloc,
  ) =>
      null;
}

class _LoaderWidgetState<Content> extends State<LoaderWidget<Content>> {
  LoaderBloc<Content> bloc;
  StreamSubscription<LoaderMessage> subscription;

  @override
  void initState() {
    super.initState();
    initBloc();
  }

  void initBloc() {
    bloc = widget.blocProvider()..fetch();
    subscription =
        bloc.message$.listen((message) => widget.messageHandler(message, bloc));
  }

  void disposeBloc() {
    subscription?.cancel();
    subscription = null;

    bloc?.dispose();
    bloc = null;
  }

  @override
  void dispose() {
    disposeBloc();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bloc.state$,
      initialData: bloc.state$.value,
      builder: (context, snapshot) =>
          widget.builder(context, snapshot.data, bloc),
    );
  }
}
