import 'package:flutter_test/flutter_test.dart';
import 'package:stream_loader/src/partial_state_change.dart';
import 'package:meta/meta.dart';

@alwaysThrows
void _aThrowsFunction() {
  throw Exception('Exception');
}

void main() {
  group('LoaderPartialStateChange', () {
    test('Create a fetch failure change', () async {
      try {
        _aThrowsFunction();
      } catch (e) {
        LoaderPartialStateChange.fetchFailure(e);
        expect(true, true);
      }
    });

    test('Create a fetch success change', () {
      const LoaderPartialStateChange.fetchSuccess('This is content');
      expect(true, true);
    });

    test('Create a fetch loading change', () {
      const LoaderPartialStateChange.fetchLoading();
      expect(true, true);
    });

    test('Create a refresh success change', () {
      const LoaderPartialStateChange.refreshSuccess('This is content');
      expect(true, true);
    });

    test('Fold when change is fetch failure', () {
      try {
        _aThrowsFunction();
      } catch (ex) {
        final value = LoaderPartialStateChange.fetchFailure(ex).fold(
          onRefreshSuccess: null,
          onFetchLoading: null,
          onFetchFailure: (e) {
            expect(ex, e);
            return 50;
          },
          onFetchSuccess: null,
        );
        expect(value, 50);
      }
    });

    test('Fold when change is fetch success', () {
      const content = 'This is content';
      final value = const LoaderPartialStateChange.fetchSuccess(content).fold(
        onFetchFailure: null,
        onFetchSuccess: (c) => c + '#Fold',
        onRefreshSuccess: null,
        onFetchLoading: null,
      );
      expect(value, content + '#Fold');
    });

    test('Fold when change is fetch loading', () {
      const expected = '#Fold';
      final value = const LoaderPartialStateChange.fetchLoading().fold(
        onFetchSuccess: null,
        onFetchLoading: () {
          return expected;
        },
        onFetchFailure: null,
        onRefreshSuccess: null,
      );
      expect(value, expected);
    });

    test('Fold when change is refresh success', () {
      const content = 'This is content';
      final value = const LoaderPartialStateChange.refreshSuccess(content).fold(
        onFetchFailure: null,
        onRefreshSuccess: (c) => c + '#Fold',
        onFetchSuccess: null,
        onFetchLoading: null,
      );
      expect(value, content + '#Fold');
    });

    test('Operator ==', () {
      // fetchSuccess
      expect(
        LoaderPartialStateChange.fetchSuccess('Content'),
        LoaderPartialStateChange.fetchSuccess('Content'),
      );
      expect(
        const LoaderPartialStateChange.fetchSuccess('Content'),
        LoaderPartialStateChange.fetchSuccess('Content'),
      );
      expect(
        const LoaderPartialStateChange.fetchSuccess('Content'),
        const LoaderPartialStateChange.fetchSuccess('Content'),
      );

      // fetchLoading
      expect(
        LoaderPartialStateChange.fetchLoading(),
        LoaderPartialStateChange.fetchLoading(),
      );
      expect(
        const LoaderPartialStateChange.fetchLoading(),
        LoaderPartialStateChange.fetchLoading(),
      );
      expect(
        const LoaderPartialStateChange.fetchLoading(),
        const LoaderPartialStateChange.fetchLoading(),
      );

      // fetchFailure
      final exception = Exception();
      expect(
        LoaderPartialStateChange.fetchFailure(exception),
        LoaderPartialStateChange.fetchFailure(exception),
      );

      // refreshSuccess
      expect(
        LoaderPartialStateChange.refreshSuccess('Content'),
        LoaderPartialStateChange.refreshSuccess('Content'),
      );
      expect(
        const LoaderPartialStateChange.refreshSuccess('Content'),
        LoaderPartialStateChange.refreshSuccess('Content'),
      );
      expect(
        const LoaderPartialStateChange.refreshSuccess('Content'),
        const LoaderPartialStateChange.refreshSuccess('Content'),
      );
    });
  });
}
