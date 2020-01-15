import 'package:flutter_test/flutter_test.dart';
import 'package:stream_loader/src/loader_state.dart';

void main() {
  group('LoaderState', () {
    test('Create initial loader state', () {
      const content = 'This is content';
      final initial = LoaderState.initial(content: content);
      expect(initial.isLoading, isTrue);
      expect(initial.error, isNull);
      expect(initial.content, content);
    });

    test('Create loader state with updates function', () {
      const content = 'This is content';
      final state = LoaderState<String>((b) => b
        ..isLoading = true
        ..error = null
        ..content = content);
      expect(state.isLoading, isTrue);
      expect(state.error, isNull);
      expect(state.content, content);
    });

    test('Throws if isLoading is null', () {
      expect(
        () => LoaderState<String>((b) => b.isLoading = null),
        throwsA(isInstanceOf<Error>()),
      );
    });

    test('Operator ==', () {
      const content = 'This is content';
      final state1 = LoaderState<String>((b) => b
        ..isLoading = true
        ..error = null
        ..content = content);
      final state2 = LoaderState<String>((b) => b
        ..isLoading = true
        ..error = null
        ..content = content);
      expect(state1, state2);
    });

    test('Rebuild', () {
      const content = 'This is content';
      final state = LoaderState<String>((b) => b
        ..isLoading = true
        ..error = null
        ..content = content);
      final expected = LoaderState<String>((b) => b
        ..isLoading = false
        ..error = null
        ..content = content + '#Changed');
      expect(
        state.rebuild(
          (b) => b
            ..isLoading = expected.isLoading
            ..content = expected.content,
        ),
        expected,
      );
    });
  });
}
