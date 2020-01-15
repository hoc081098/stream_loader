import 'package:flutter_test/flutter_test.dart';
import 'package:stream_loader/src/loader_bloc.dart';
import 'package:stream_loader/src/loader_state.dart';

Future<void> _delay(int milliseconds) =>
    Future.delayed(Duration(milliseconds: milliseconds));

void main() {
  group('LoaderBloc', () {
    group('LoaderFunction return empty stream', () {
      test('Emit inital state', () async {
        const initialContent = 'Initial content';
        final initialState = LoaderState.initial(content: initialContent);

        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {},
          initialContent: initialContent,
        );

        final expectFuture = expect(
          loaderBloc.state$,
          emitsInOrder([initialState, emitsDone]),
        );

        await loaderBloc.dispose();
        await expectFuture;
      });
    });

    group('LoaderFunction return stream that has many values', () {
      test('Emit inital state and states from loaderFunction', () async {
        const initialContent = 'Initial content';
        const repeatCount = 5;
        const multiDelay = 10;
        final totalTime =
            List.generate(repeatCount, (i) => (i + 1) * multiDelay)
                .fold(0, (a, e) => a + e);
        const delta = 500;
        final initialState = LoaderState.initial(content: initialContent);

        final loaderBloc = LoaderBloc<String>(
          loaderFunction: () async* {
            for (int i = 0; i < repeatCount; i++) {
              yield '$initialContent#$i';
              await _delay(multiDelay * (i + 1));
            }
          },
          initialContent: initialContent,
        );

        final expectFuture = expect(
          loaderBloc.state$,
          emitsInOrder(
            [
              initialState,
              ...[
                for (int i = 0; i < repeatCount; i++)
                  LoaderState<String>(
                    (b) => b
                      ..content = '$initialContent#$i'
                      ..isLoading = false
                      ..error = null,
                  )
              ],
              emitsDone,
            ],
          ),
        );

        loaderBloc.fetch();
        await _delay(totalTime + delta);
        await loaderBloc.dispose();

        await expectFuture;
      });
    });
  });
}
