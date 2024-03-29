import 'dart:async';

import 'package:flutter/material.dart';

import 'loader_bloc.dart';
import 'loader_message.dart';
import 'loader_state.dart';

/// Signature for strategies that build widgets based on [LoaderState].
typedef LoaderBuilder<Content extends Object> = Widget Function(
  BuildContext context,
  LoaderState<Content> state,
  LoaderBloc<Content> bloc,
);

/// The handler for [LoaderMessage].
typedef LoaderMessageHandler<Content extends Object> = void Function(
  BuildContext context,
  LoaderMessage<Content> message,
  LoaderBloc<Content> bloc,
);

/// Widget that builds itself based on the latest data of [LoaderBloc.state$]
class LoaderWidget<Content extends Object> extends StatefulWidget {
  /// Function that returns a [LoaderBloc]
  final LoaderBloc<Content> Function() blocProvider;

  /// Function that handle [LoaderMessage]
  final LoaderMessageHandler<Content>? messageHandler;

  /// Function used to build widget base on stream
  final LoaderBuilder<Content> builder;

  /// Construct a [LoaderWidget]
  /// The [blocProvider] must be not null
  ///
  /// The [builder] must be not null
  ///
  /// The [messageHandler] can be null. When it is null, it will equal to [_emptyMessageHandler]
  const LoaderWidget({
    Key? key,
    required this.blocProvider,
    required this.builder,
    this.messageHandler,
  }) : super(key: key);

  @override
  State<LoaderWidget<Content>> createState() => _LoaderWidgetState<Content>();
}

class _LoaderWidgetState<Content extends Object>
    extends State<LoaderWidget<Content>> {
  LoaderBloc<Content>? bloc;
  StreamSubscription<LoaderMessage>? subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (bloc == null) {
      initBloc();
    }
  }

  @override
  void didUpdateWidget(LoaderWidget<Content> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final handler = widget.messageHandler;
    if (handler != oldWidget.messageHandler) {
      subscription?.cancel();

      if (handler != null) {
        subscription = requireBloc.message$
            .listen((message) => handler(context, message, requireBloc));
      }
    }
  }

  void initBloc() {
    assert(bloc == null);
    assert(subscription == null);

    bloc = widget.blocProvider()..fetch();

    final handler = widget.messageHandler;
    if (handler != null) {
      subscription = requireBloc.message$
          .listen((message) => handler(context, message, requireBloc));
    }
  }

  void disposeBloc() {
    subscription?.cancel();
    subscription = null;

    bloc?.dispose();
    bloc = null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  LoaderBloc<Content> get requireBloc => bloc!;

  @override
  void dispose() {
    disposeBloc();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = requireBloc;

    return StreamBuilder<LoaderState<Content>>(
      stream: bloc.state$,
      initialData: bloc.state$.value,
      builder: (context, snapshot) {
        return widget.builder(
          context,
          snapshot.requireData,
          bloc,
        );
      },
    );
  }
}
