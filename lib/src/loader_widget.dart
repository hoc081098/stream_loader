import 'dart:async';

import 'package:flutter/material.dart';

import 'loader_bloc.dart';
import 'loader_message.dart';
import 'loader_state.dart';

/// The [state] is nullable
/// The [bloc] is nullable
typedef LoaderBuilder<Content> = Widget Function(
  BuildContext context,
  LoaderState<Content> state,
  LoaderBloc<Content> bloc,
);

/// The [bloc] is nullable
typedef LoaderMessageHandler<Content> = void Function(
  LoaderMessage<Content> message,
  LoaderBloc<Content> bloc,
);

/// Widget that builds itself based on the latest data of [LoaderBloc.state$]
class LoaderWidget<Content> extends StatefulWidget {
  /// Function that returns a [LoaderBloc]
  final LoaderBloc<Content> Function() blocProvider;

  /// Function that handle [LoaderMessage]
  final LoaderMessageHandler<Content> messageHandler;

  /// Function used to build widget base on stream
  final LoaderBuilder<Content> builder;

  /// Construct a [LoaderWidget]
  /// The [blocProvider] must be not null
  ///
  /// The [builder] must be not null
  ///
  /// The [messageHandler] can be null. When it is null, it will equal to [_emptyMessageHandler]
  const LoaderWidget({
    Key key,
    @required this.blocProvider,
    @required this.builder,
    LoaderMessageHandler<Content> messageHandler,
  })  : assert(blocProvider != null),
        assert(builder != null),
        messageHandler = messageHandler ?? _emptyMessageHandler,
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

  @override
  void didUpdateWidget(LoaderWidget<Content> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messageHandler != oldWidget.messageHandler) {
      subscription?.cancel();
      subscription = bloc?.message$
          ?.listen((message) => widget.messageHandler(message, bloc));
    }
  }

  void initBloc() {
    assert(bloc == null);
    assert(subscription == null);

    bloc = widget.blocProvider();
    bloc?.fetch();
    subscription = bloc?.message$
        ?.listen((message) => widget.messageHandler(message, bloc));
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
      stream: bloc?.state$ ?? Stream.empty(),
      initialData: bloc?.state$?.value,
      builder: (context, snapshot) => widget.builder(
        context,
        snapshot.data,
        bloc,
      ),
    );
  }
}
