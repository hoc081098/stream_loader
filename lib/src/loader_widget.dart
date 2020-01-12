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
    this.messageHandler,
  })  : assert(blocProvider != null),
        assert(builder != null),
        super(key: key);

  @override
  _LoaderWidgetState<Content> createState() => _LoaderWidgetState<Content>();
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

  @override
  void didUpdateWidget(LoaderWidget<Content> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blocProvider != widget.blocProvider) {
      disposeBloc();
      initBloc();
      return;
    }
    if (oldWidget.builder != widget.builder) {
      setState(() {});
      return;
    }
    if (oldWidget.messageHandler != widget.messageHandler) {
      subscription?.cancel();
      subscription = bloc.message$
          .listen((message) => widget.messageHandler(message, bloc));
      return;
    }
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
