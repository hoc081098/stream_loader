import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stream_loader/src/loader_bloc.dart';
import 'package:stream_loader/src/loader_widget.dart';

class BlocProviderMock<T> extends Mock {
  LoaderBloc<T> call();
}

void main() {
  group('LoaderWidget', () {
    group('Assert', () {
      test('blocProvider', () {
        expect(
          () => LoaderWidget<String>(
            blocProvider: null,
            builder: (context, state, bloc) => Container(),
          ),
          throwsAssertionError,
        );
      });

      test('blocProvider', () {
        expect(
          () => LoaderWidget<String>(
            blocProvider: () => LoaderBloc(
              loaderFunction: () => Stream.empty(),
            ),
            builder: null,
          ),
          throwsAssertionError,
        );
      });
    });

    testWidgets('Calls blocProvider once', (tester) async {
      final blocProvider = BlocProviderMock<String>();
      when(blocProvider.call()).thenAnswer(
        (_) => LoaderBloc<String>(
          loaderFunction: () async* {},
        ),
      );
      await tester.pumpWidget(
        LoaderWidget<String>(
          blocProvider: blocProvider,
          builder: (context, state, bloc) => Container(),
        ),
      );
      await tester.pumpWidget(
        LoaderWidget<String>(
          blocProvider: blocProvider,
          builder: (context, state, bloc) => Container(),
        ),
      );
      await tester.pumpWidget(Container());
      verify(blocProvider.call()).called(1);
    });

    testWidgets('Calls bloc dispose', (tester) async {

    });
  });
}
