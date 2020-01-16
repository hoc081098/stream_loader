import 'package:flutter_test/flutter_test.dart';
import 'package:stream_loader/stream_loader.dart';
import 'package:meta/meta.dart';

@alwaysThrows
void _aThrowsFunction() {
  throw Exception('Exception');
}

void main() {
  group('LoaderMessage', () {
    test('Create a fetch failure message', () async {
      try {
        _aThrowsFunction();
      } catch (e, s) {
        LoaderMessage.fetchFailure(e, s);
        expect(true, true);
      }
    });

    test('Create a fetch success message', () {
      const LoaderMessage.fetchSuccess('This is content');
      expect(true, true);
    });

    test('Create a refresh failure message', () async {
      try {
        _aThrowsFunction();
      } catch (e, s) {
        LoaderMessage.refreshFailure(e, s);
        expect(true, true);
      }
    });

    test('Create a refresh success message', () {
      const LoaderMessage.refreshSuccess('This is content');
      expect(true, true);
    });

    test('Fold when message is fetch failure', () {
      try {
        _aThrowsFunction();
      } catch (exception, stackTrace) {
        final loaderMessage = LoaderMessage.fetchFailure(exception, stackTrace);
        final value = loaderMessage.fold(
          onFetchFailure: (e, s) {
            expect(exception, e);
            expect(stackTrace, s);
            return 50;
          },
          onFetchSuccess: null,
          onRefreshFailure: null,
          onRefreshSuccess: null,
        );
        expect(value, 50);

        expect(
          loaderMessage.fold(
            onFetchFailure: null,
            onFetchSuccess: null,
            onRefreshFailure: null,
            onRefreshSuccess: null,
          ),
          isNull,
        );
      }
    });

    test('Fold when message is fetch success', () {
      const content = 'This is content';
      const loaderMessage = LoaderMessage.fetchSuccess(content);
      final value = loaderMessage.fold(
        onFetchFailure: null,
        onFetchSuccess: (c) => c + '#Fold',
        onRefreshFailure: null,
        onRefreshSuccess: null,
      );
      expect(value, content + '#Fold');

      expect(
        loaderMessage.fold(
          onFetchFailure: null,
          onFetchSuccess: null,
          onRefreshFailure: null,
          onRefreshSuccess: null,
        ),
        isNull,
      );
    });

    test('Fold when message is refresh failure', () {
      try {
        _aThrowsFunction();
      } catch (exception, stackTrace) {
        final loaderMessage = LoaderMessage.refreshFailure(exception, stackTrace);
        final value = loaderMessage.fold(
          onRefreshFailure: (e, s) {
            expect(exception, e);
            expect(stackTrace, s);
            return 50;
          },
          onFetchSuccess: null,
          onFetchFailure: null,
          onRefreshSuccess: null,
        );
        expect(value, 50);

        expect(
          loaderMessage.fold(
            onFetchFailure: null,
            onFetchSuccess: null,
            onRefreshFailure: null,
            onRefreshSuccess: null,
          ),
          isNull,
        );
      }
    });

    test('Fold when message is refresh success', () {
      const content = 'This is content';
      const loaderMessage = LoaderMessage.refreshSuccess(content);
      final value = loaderMessage.fold(
        onFetchFailure: null,
        onRefreshSuccess: (c) => c + '#Fold',
        onRefreshFailure: null,
        onFetchSuccess: null,
      );
      expect(value, content + '#Fold');

      expect(
        loaderMessage.fold(
          onFetchFailure: null,
          onFetchSuccess: null,
          onRefreshFailure: null,
          onRefreshSuccess: null,
        ),
        isNull,
      );
    });

    test('Operator ==', () {
      // refreshSuccess
      expect(
        LoaderMessage.refreshSuccess('Content'),
        LoaderMessage.refreshSuccess('Content'),
      );
      expect(
        const LoaderMessage.refreshSuccess('Content'),
        LoaderMessage.refreshSuccess('Content'),
      );
      expect(
        const LoaderMessage.refreshSuccess('Content'),
        const LoaderMessage.refreshSuccess('Content'),
      );

      // fetchSuccess
      expect(
        LoaderMessage.fetchSuccess('Content'),
        LoaderMessage.fetchSuccess('Content'),
      );
      expect(
        const LoaderMessage.fetchSuccess('Content'),
        LoaderMessage.fetchSuccess('Content'),
      );
      expect(
        const LoaderMessage.fetchSuccess('Content'),
        const LoaderMessage.fetchSuccess('Content'),
      );

      final exception = Exception();
      // fetchFailure
      expect(
        LoaderMessage.fetchFailure(exception, null),
        LoaderMessage.fetchFailure(exception, null),
      );

      // refreshFailure
      expect(
        LoaderMessage.refreshFailure(exception, null),
        LoaderMessage.refreshFailure(exception, null),
      );
    });
  });
}
