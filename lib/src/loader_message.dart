import 'package:flutter/foundation.dart';

/// Class that represents a message event
@immutable
abstract class LoaderMessage<Content> {
  const LoaderMessage._();

  /// Construct a message that represents a failed fetching
  const factory LoaderMessage.fetchFailure(
      dynamic error, StackTrace stackTrace) = _FetchFailure<Content>;

  /// Construct a message that represents a successful fetching
  const factory LoaderMessage.fetchSuccess(Content content) =
      _FetchSuccess<Content>;

  /// Construct a message that represents a failed refreshing
  const factory LoaderMessage.refreshFailure(
      dynamic error, StackTrace stackTrace) = _RefreshFailure<Content>;

  /// Construct a message that represents a successful refreshing
  const factory LoaderMessage.refreshSuccess(Content content) =
      _RefreshSuccess<Content>;

  /// Fold all cases into single value
  R fold<R>({
    @required R Function(dynamic error, StackTrace stackTrace) onFetchFailure,
    @required R Function(Content data) onFetchSuccess,
    @required R Function(dynamic error, StackTrace stackTrace) onRefreshFailure,
    @required R Function(Content data) onRefreshSuccess,
  }) {
    // avoid null error
    onFetchFailure ??= (_, __) => null;
    onFetchSuccess ??= (_) => null;
    onRefreshFailure ??= (_, __) => null;
    onRefreshSuccess ??= (_) => null;

    if (this is _FetchFailure<Content>) {
      final failure = this as _FetchFailure<Content>;
      return onFetchFailure(failure.error, failure.stackTrace);
    }
    if (this is _FetchSuccess<Content>) {
      return onFetchSuccess((this as _FetchSuccess<Content>).content);
    }
    if (this is _RefreshFailure<Content>) {
      final failure = this as _RefreshFailure<Content>;
      return onRefreshFailure(failure.error, failure.stackTrace);
    }
    if (this is _RefreshSuccess<Content>) {
      return onRefreshSuccess((this as _RefreshSuccess<Content>).content);
    }
    throw StateError('Unknown type $this');
  }
}

class _FetchFailure<Content> extends LoaderMessage<Content> {
  final dynamic error;
  final StackTrace stackTrace;

  const _FetchFailure(this.error, this.stackTrace) : super._();
}

class _FetchSuccess<Content> extends LoaderMessage<Content> {
  final Content content;

  const _FetchSuccess(this.content) : super._();
}

class _RefreshFailure<Content> extends LoaderMessage<Content> {
  final dynamic error;
  final StackTrace stackTrace;

  const _RefreshFailure(this.error, this.stackTrace) : super._();
}

class _RefreshSuccess<Content> extends LoaderMessage<Content> {
  final Content content;

  const _RefreshSuccess(this.content) : super._();
}
