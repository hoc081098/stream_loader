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
        final partialStateChange = LoaderPartialStateChange.fetchFailure(ex);
        final value = partialStateChange.fold(
          onRefreshSuccess: null,
          onFetchLoading: null,
          onFetchFailure: (e) {
            expect(ex, e);
            return 50;
          },
          onFetchSuccess: null,
        );
        expect(value, 50);

        expect(
          partialStateChange.fold(
            onFetchSuccess: null,
            onFetchLoading: null,
            onFetchFailure: null,
            onRefreshSuccess: null,
          ),
          isNull,
        );
      }
    });

    test('Fold when change is fetch success', () {
      const content = 'This is content';
      const partialStateChange = LoaderPartialStateChange.fetchSuccess(content);
      final value = partialStateChange.fold(
        onFetchFailure: null,
        onFetchSuccess: (c) => c + '#Fold',
        onRefreshSuccess: null,
        onFetchLoading: null,
      );
      expect(value, content + '#Fold');

      expect(
        partialStateChange.fold(
          onFetchSuccess: null,
          onFetchLoading: null,
          onFetchFailure: null,
          onRefreshSuccess: null,
        ),
        isNull,
      );
    });

    test('Fold when change is fetch loading', () {
      const expected = '#Fold';
      const partialStateChange = LoaderPartialStateChange.fetchLoading();
      final value = partialStateChange.fold(
        onFetchSuccess: null,
        onFetchLoading: () {
          return expected;
        },
        onFetchFailure: null,
        onRefreshSuccess: null,
      );
      expect(value, expected);

      expect(
        partialStateChange.fold(
          onFetchSuccess: null,
          onFetchLoading: null,
          onFetchFailure: null,
          onRefreshSuccess: null,
        ),
        isNull,
      );
    });

    test('Fold when change is refresh success', () {
      const content = 'This is content';
      const partialStateChange =
          LoaderPartialStateChange.refreshSuccess(content);
      final value = partialStateChange.fold(
        onFetchFailure: null,
        onRefreshSuccess: (c) => c + '#Fold',
        onFetchSuccess: null,
        onFetchLoading: null,
      );
      expect(value, content + '#Fold');

      expect(
        partialStateChange.fold(
          onFetchSuccess: null,
          onFetchLoading: null,
          onFetchFailure: null,
          onRefreshSuccess: null,
        ),
        isNull,
      );
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

    test('hashCode', () {
      // fetchSuccess
      expect(
        LoaderPartialStateChange.fetchSuccess('Content').hashCode,
        LoaderPartialStateChange.fetchSuccess('Content').hashCode,
      );
      expect(
        const LoaderPartialStateChange.fetchSuccess('Content').hashCode,
        LoaderPartialStateChange.fetchSuccess('Content').hashCode,
      );
      expect(
        const LoaderPartialStateChange.fetchSuccess('Content').hashCode,
        const LoaderPartialStateChange.fetchSuccess('Content').hashCode,
      );

      // fetchLoading
      expect(
        LoaderPartialStateChange.fetchLoading().hashCode,
        LoaderPartialStateChange.fetchLoading().hashCode,
      );
      expect(
        const LoaderPartialStateChange.fetchLoading().hashCode,
        LoaderPartialStateChange.fetchLoading().hashCode,
      );
      expect(
        const LoaderPartialStateChange.fetchLoading().hashCode,
        const LoaderPartialStateChange.fetchLoading().hashCode,
      );

      // fetchFailure
      final exception = Exception();
      expect(
        LoaderPartialStateChange.fetchFailure(exception).hashCode,
        LoaderPartialStateChange.fetchFailure(exception).hashCode,
      );

      // refreshSuccess
      expect(
        LoaderPartialStateChange.refreshSuccess('Content').hashCode,
        LoaderPartialStateChange.refreshSuccess('Content').hashCode,
      );
      expect(
        const LoaderPartialStateChange.refreshSuccess('Content').hashCode,
        LoaderPartialStateChange.refreshSuccess('Content').hashCode,
      );
      expect(
        const LoaderPartialStateChange.refreshSuccess('Content').hashCode,
        const LoaderPartialStateChange.refreshSuccess('Content').hashCode,
      );
    });
  });
}
