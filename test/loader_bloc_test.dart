import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:stream_loader/src/loader_bloc.dart';
import 'package:stream_loader/src/loader_message.dart';
import 'package:stream_loader/src/loader_state.dart';

Future<void> _delay(int milliseconds) =>
    Future.delayed(Duration(milliseconds: milliseconds));

void main() {
  group('LoaderBloc', () {
    group('LoaderFunction return a empty stream', () {
      test('Emit done event', () async {
        const initialContent = 'Initial content';
        final initialState = LoaderState.initial(content: initialContent);

        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {},
          initialContent: initialContent,
        );

        expect(loaderBloc.state$.value, initialState);
        final expectFuture = expectLater(
          loaderBloc.state$,
          emitsDone,
        );

        loaderBloc.fetch();
        await _delay(2000);
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

        loaderBloc.fetch();
        await _delay(2000);
        await loaderBloc.dispose();

        await expectFuture;
      });
    });

    group('LoaderFunction return a stream that has no data and error', () {
      test('Emit error state', () async {
        const initialContent = 'Initial content';
        final initialState = LoaderState.initial(content: initialContent);
        final exception = Exception();

        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {
            throw exception;
          },
          initialContent: initialContent,
        );

        expect(loaderBloc.state$.requireValue, initialState);
        final expectFuture = expectLater(
          loaderBloc.state$,
          emitsInOrder([
            LoaderState<String>((b) => b
              ..content = initialContent
              ..isLoading = false
              ..error = exception),
            emitsDone,
          ]),
        );

        loaderBloc.fetch();
        await _delay(2000);
        await loaderBloc.dispose();

        await expectFuture;
      });

      test('Emit fetch error message', () async {
        final exception = Exception();
        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {
            throw exception;
          },
          initialContent: 'Initial content',
        );

        final expectFuture = expectLater(
          loaderBloc.message$,
          emitsInOrder([
            isInstanceOf<LoaderMessage<String>>(),
            emitsDone,
          ]),
        );

        loaderBloc.fetch();
        await _delay(2000);
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
                .fold<int>(0, (a, e) => a + e);

        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {
            for (var i = 0; i < repeatCount; i++) {
              yield '$initialContent#$i';
              await _delay(multiDelay * (i + 1));
            }
          },
          initialContent: initialContent,
          logger: print,
        );

        final expectFuture = expectFunc(loaderBloc);

        loaderBloc.fetch();
        await _delay(totalTime + delta);
        await loaderBloc.dispose();

        await expectFuture;
        print('Done $repeatCount');
      }

      test('Emit states from loaderFunction', () async {
        final futures = [
          for (int repeatCount = 1; repeatCount <= 5; repeatCount++)
            _one(
              repeatCount,
              (loaderBloc) {
                expect(loaderBloc.state$.value, initialState);

                return expectLater(
                  loaderBloc.state$,
                  emitsInOrder(
                    [
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
                );
              },
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

    group('RefreshFunction return a empty stream', () {
      const initialContent = 'Initial content';
      final initialState = LoaderState.initial(content: initialContent);

      late LoaderBloc<String> loaderBloc;

      setUp(() {
        loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {},
          initialContent: initialContent,
        );
      });

      tearDown(() => loaderBloc.dispose());

      test('Emit done event', () async {
        expect(loaderBloc.state$.value, initialState);
        final expectFuture = expectLater(
          loaderBloc.state$,
          emitsDone,
        );

        loaderBloc.fetch();
        await _delay(2000);
        await loaderBloc.refresh();
        await _delay(2000);
        await loaderBloc.dispose();

        await expectFuture;
      });

      test('Message stream is empty', () async {
        final expectFuture = expectLater(
          loaderBloc.message$,
          emitsDone,
        );

        loaderBloc.fetch();
        await _delay(2000);
        await loaderBloc.refresh();
        await _delay(2000);
        await loaderBloc.dispose();

        await expectFuture;
      });
    });

    group('RefreshFunction return a stream that has no data and error', () {
      test('Emit done event', () async {
        const initialContent = 'Initial content';
        final initialState = LoaderState.initial(content: initialContent);
        final exception = Exception();

        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {},
          initialContent: initialContent,
          refresherFunction: () => Stream.error(exception),
        );

        expect(loaderBloc.state$.value, initialState);
        final expectFuture = expectLater(
          loaderBloc.state$,
          emitsDone,
        );

        loaderBloc.fetch();
        await _delay(2000);
        await loaderBloc.refresh();
        await _delay(2000);
        await loaderBloc.dispose();

        await expectFuture;
      });

      test('Emit refresh error message', () async {
        final exception = Exception();
        final loaderBloc = LoaderBloc<String>(
            loaderFunction: () async* {},
            initialContent: 'Initial content',
            refresherFunction: () async* {
              throw exception;
            });

        final expectFuture = expectLater(
          loaderBloc.message$,
          emitsInOrder([
            isInstanceOf<LoaderMessage<String>>(),
            emitsDone,
          ]),
        );

        loaderBloc.fetch();
        await _delay(2000);
        await loaderBloc.refresh();
        await _delay(2000);
        await loaderBloc.dispose();

        await expectFuture;
      });
    });

    group('RefreshFunction return a stream that has values', () {
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
                .fold<int>(0, (a, e) => a + e);

        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () => Stream.empty(),
          refresherFunction: () async* {
            for (var i = 0; i < repeatCount; i++) {
              yield '$initialContent#$i';
              await _delay(multiDelay * (i + 1));
            }
          },
          initialContent: initialContent,
        );

        final expectFuture = expectFunc(loaderBloc);

        loaderBloc.fetch();
        await _delay(100);
        await loaderBloc.refresh();
        await _delay(totalTime + delta);
        await loaderBloc.dispose();

        await expectFuture;
        print('Done $repeatCount');
      }

      test('Emits updated states from refreshFunction', () async {
        final futures = [
          for (int repeatCount = 1; repeatCount <= 5; repeatCount++)
            _one(
              repeatCount,
              (loaderBloc) {
                expect(loaderBloc.state$.value, initialState);

                return expectLater(
                  loaderBloc.state$,
                  emitsInOrder(
                    [
                      ...[
                        for (int j = 0; j < repeatCount; j++)
                          LoaderState<String>(
                            (b) => b
                              ..content = '$initialContent#$j'
                              ..isLoading = true
                              ..error = null,
                          )
                      ],
                      emitsDone,
                    ],
                  ),
                );
              },
            ),
        ];
        await Future.wait(futures);
      });

      test('Emit refresh success messages', () async {
        final futures = [
          for (int repeatCount = 1; repeatCount <= 5; repeatCount++)
            _one(
              repeatCount,
              (loaderBloc) => expectLater(
                loaderBloc.message$,
                emitsInOrder([
                  ...[
                    for (int j = 0; j < repeatCount; j++)
                      LoaderMessage.refreshSuccess('$initialContent#$j')
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
