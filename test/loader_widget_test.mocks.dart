import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:stream_loader/src/loader_bloc.dart' as _i2;
import 'package:stream_loader/src/loader_state.dart' as _i5;

import 'loader_widget_test.dart' as _i4;

// ignore_for_file: comment_references

// ignore_for_file: unnecessary_parenthesis

class _FakeLoaderBloc<Content extends Object> extends _i1.Fake
    implements _i2.LoaderBloc<Content> {}

class _FakeWidget extends _i1.Fake implements _i3.Widget {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      super.toString();
}

/// A class which mocks [BlocProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockBlocProvider<T extends Object> extends _i1.Mock
    implements _i4.BlocProvider<T> {
  MockBlocProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.LoaderBloc<T> call() =>
      (super.noSuchMethod(Invocation.method(#call, []), _FakeLoaderBloc<T>())
          as _i2.LoaderBloc<T>);
}

/// A class which mocks [LoaderBuilder].
///
/// See the documentation for Mockito's code generation for more information.
class MockLoaderBuilder<T extends Object> extends _i1.Mock
    implements _i4.LoaderBuilder<T> {
  MockLoaderBuilder() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Widget call(_i3.BuildContext? context, _i5.LoaderState<T>? state,
          _i2.LoaderBloc<T>? bloc) =>
      (super.noSuchMethod(
              Invocation.method(#call, [context, state, bloc]), _FakeWidget())
          as _i3.Widget);
}
