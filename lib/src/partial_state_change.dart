import 'package:flutter/foundation.dart';

/// Class that represents a partial state change
@immutable
abstract class LoaderPartialStateChange<Content> {
  const LoaderPartialStateChange._();

  /// Construct a change that represents a successful fetching
  const factory LoaderPartialStateChange.fetchSuccess(Content data) =
      _FetchSuccess<Content>;

  /// Construct a change that represents a in-progressing fetching
  const factory LoaderPartialStateChange.fetchLoading() =
      _FetchLoading<Content>;

  /// Construct a change that represents a failed fetching
  const factory LoaderPartialStateChange.fetchFailure(dynamic error) =
      _FetchFailure<Content>;

  /// Construct a change that represents a successful refreshing
  const factory LoaderPartialStateChange.refreshSuccess(Content data) =
      _RefreshSuccess<Content>;

  /// Fold all cases into single value
  R fold<R>({
    @required R Function(Content content) onFetchSuccess,
    @required R Function() onFetchLoading,
    @required R Function(dynamic error) onFetchFailure,
    @required R Function(Content content) onRefreshSuccess,
  }) {
    // avoid null error
    onFetchSuccess ??= (_) => null;
    onFetchLoading ??= () => null;
    onFetchFailure ??= (_) => null;
    onRefreshSuccess ??= (_) => null;

    if (this is _FetchSuccess<Content>) {
      return onFetchSuccess((this as _FetchSuccess<Content>).content);
    }
    if (this is _FetchLoading<Content>) {
      return onFetchLoading();
    }
    if (this is _FetchFailure<Content>) {
      return onFetchFailure((this as _FetchFailure<Content>).error);
    }
    if (this is _RefreshSuccess<Content>) {
      return onRefreshSuccess((this as _RefreshSuccess<Content>).content);
    }
    throw StateError('Unknown type of $this');
  }
}

class _FetchSuccess<Content> extends LoaderPartialStateChange<Content> {
  final Content content;

  const _FetchSuccess(this.content) : super._();
}

class _FetchLoading<Content> extends LoaderPartialStateChange<Content> {
  const _FetchLoading() : super._();
}

class _FetchFailure<Content> extends LoaderPartialStateChange<Content> {
  final dynamic error;

  const _FetchFailure(this.error) : super._();
}

class _RefreshSuccess<Content> extends LoaderPartialStateChange<Content> {
  final Content content;

  const _RefreshSuccess(this.content) : super._();
}
