import 'package:built_value/built_value.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_loader/src/loader_bloc.dart';
import 'package:stream_loader/src/loader_message.dart';
import 'package:stream_loader/src/loader_state.dart';

Future<void> _delay(int milliseconds) =>
    Future.delayed(Duration(milliseconds: milliseconds));

void main() {
  group('LoaderBloc', () {
    group('Assert', () {
      test('loaderFunction', () {
        expect(
          () => LoaderBloc(loaderFunction: null),
          throwsAssertionError,
        );
      });

      test('enableLogger', () {
        expect(
          () => LoaderBloc(
            loaderFunction: () async* {},
            enableLogger: null,
          ),
          throwsAssertionError,
        );
      });
    });

    group('LoaderFunction return a empty stream', () {
      test('Emit inital state', () async {
        const initialContent = 'Initial content';
        final initialState = LoaderState.initial(content: initialContent);

        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {},
          initialContent: initialContent,
        );

        final expectFuture = expectLater(
          loaderBloc.state$,
          emitsInOrder([initialState, emitsDone]),
        );

        await loaderBloc.dispose();
        await expectFuture;
      });

      test('Message stream is empty', () async {
        const initialContent = 'Initial content';

        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {},
          initialContent: initialContent,
        );

        final expectFuture = expectLater(
          loaderBloc.message$,
          emitsDone,
        );

        await loaderBloc.dispose();
        await expectFuture;
      });
    });

    group('LoaderFunction return a stream that has values', () {
      const multiDelay = 10;
      const delta = 500;
      const initialContent = 'Initial content';
      final initialState = LoaderState.initial(content: initialContent);

      Future<void> _one(
        int repeatCount,
        Future<void> Function(LoaderBloc bloc) expectFunc,
      ) async {
        final totalTime =
            List.generate(repeatCount, (i) => (i + 1) * multiDelay)
                .fold(0, (a, e) => a + e);

        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {
            for (int i = 0; i < repeatCount; i++) {
              yield '$initialContent#$i';
              await _delay(multiDelay * (i + 1));
            }
          },
          initialContent: initialContent,
          enableLogger: false,
        );

        final expectFuture = expectFunc(loaderBloc);

        loaderBloc.fetch();
        await _delay(totalTime + delta);
        await loaderBloc.dispose();

        await expectFuture;
        print('Done $repeatCount');
      }

      test('Emit inital state and states from loaderFunction', () async {
        final futures = [
          for (int repeatCount = 1; repeatCount <= 5; repeatCount++)
            _one(
              repeatCount,
              (loaderBloc) => expectLater(
                loaderBloc.state$,
                emitsInOrder(
                  [
                    initialState,
                    ...[
                      for (int j = 0; j < repeatCount; j++)
                        LoaderState<String>(
                          (b) => b
                            ..content = '$initialContent#$j'
                            ..isLoading = false
                            ..error = null,
                        )
                    ],
                    emitsDone,
                  ],
                ),
              ),
            ),
        ];
        await Future.wait(futures);
      });

      test('Emit fetch success messages', () async {
        final futures = [
          for (int repeatCount = 1; repeatCount <= 5; repeatCount++)
            _one(
              repeatCount,
              (loaderBloc) => expectLater(
                loaderBloc.message$,
                emitsInOrder([
                  ...[
                    for (int j = 0; j < repeatCount; j++)
                      LoaderMessage.fetchSuccess('$initialContent#$j')
                  ],
                  emitsDone,
                ]),
              ),
            ),
        ];
        await Future.wait(futures);
      });
    });
  });
}
