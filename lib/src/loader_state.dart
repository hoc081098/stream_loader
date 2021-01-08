import 'package:built_value/built_value.dart';
import 'package:flutter/foundation.dart';

part 'loader_state.g.dart';

// ignore_for_file: hash_and_equals

/// View state that exposed to widget builder
@immutable
abstract class LoaderState<Content extends Object>
    implements Built<LoaderState<Content>, LoaderStateBuilder<Content>> {
  /// Content (should implements [Built] class from `built_value` package)
  Content? get content;

  /// Is fetching in-progress
  bool get isLoading;

  /// Error when fetching is failed
  Object? get error;

  LoaderState._();

  /// Construct a [LoaderState] and apply [updates] immediately
  factory LoaderState([void Function(LoaderStateBuilder<Content>) updates]) =
      _$LoaderState<Content>;

  /// Initial view state with [content], [isLoading] is true and [error] is null
  factory LoaderState.initial({Content? content}) =>
      LoaderState<Content>((b) => b
        ..content = content
        ..isLoading = true
        ..error = null);

  @memoized
  @override
  int get hashCode;
}
