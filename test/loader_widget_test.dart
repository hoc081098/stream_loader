import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stream_loader/src/loader_bloc.dart';
import 'package:stream_loader/src/loader_state.dart';
import 'package:stream_loader/src/loader_widget.dart';

class BlocProviderMock<T> extends Mock {
  LoaderBloc<T> call();
}

class MockBuilder<T> extends Mock {
  Widget call(
    BuildContext context,
    LoaderState<T> state,
    LoaderBloc<T> bloc,
  );
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

      test('builder', () {
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

    testWidgets('null messageHandler', (tester) async {
      await tester.pumpWidget(
        LoaderWidget<String>(
          blocProvider: () => LoaderBloc(
            loaderFunction: () => Stream.empty(),
          ),
          builder: (context, state, bloc) => Container(),
          messageHandler: null,
        ),
      );
      await tester.pumpWidget(Container());
      expect(true, isTrue);
    });

    testWidgets(
      'blocProvider returns null, builder is called once with null state',
      (tester) async {
        final mockBuilder = MockBuilder<String>();
        when(mockBuilder.call(any, any, any)).thenReturn(Container());

        await tester.pumpWidget(
          LoaderWidget<String>(
            blocProvider: () => null,
            builder: mockBuilder,
          ),
        );
        await tester.pumpWidget(Container());
        verify(
          mockBuilder.call(
            any,
            null /* state */,
            null /* bloc */,
          ),
        ).called(1);
      },
    );

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

    /*testWidgets('Calls builder when state stream emits', (tester) async {
      await tester.runAsync(
        () async {
          final states = <String>[];
          final completer = Completer();

          await tester.pumpWidget(
            LoaderWidget<String>(
              blocProvider: () {
                final loaderBloc = LoaderBloc(
                  loaderFunction: () async* {
                    for (int i = 0; i < 5; i++) {
                      yield '#$i';
                    }
                    print('call...');
                    completer.complete();
                  },
                  initialContent: '#0',
                );
                return loaderBloc;
              },
              builder: (context, state, bloc) {
                states.add(state.content);
                print('Builder ${state.content}');
                return Container();
              },
            ),
          );

          await completer.future;
          print(states);
        },
        additionalTime: const Duration(seconds: 10),
      );
    });*/
  });
}
