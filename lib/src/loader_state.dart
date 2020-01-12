import 'package:built_value/built_value.dart';
import 'package:flutter/foundation.dart';

part 'loader_state.g.dart';

@immutable
abstract class LoaderState<Content>
    implements Built<LoaderState<Content>, LoaderStateBuilder<Content>> {
  @nullable
  Content get content;

  bool get isLoading;

  @nullable
  Object get error;

  LoaderState._();

  factory LoaderState([void Function(LoaderStateBuilder<Content>) updates]) =
      _$LoaderState<Content>;

  factory LoaderState.initial(Content content) => LoaderState<Content>((b) => b
    ..content = content
    ..isLoading = true
    ..error = null);
}
