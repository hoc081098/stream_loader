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
  const factory LoaderPartialStateChange.fetchFailure(Object error) =
      _FetchFailure<Content>;

  /// Construct a change that represents a successful refreshing
  const factory LoaderPartialStateChange.refreshSuccess(Content data) =
      _RefreshSuccess<Content>;

  /// Fold all cases into single value
  R fold<R>({
    required R Function(Content content) onFetchSuccess,
    required R Function() onFetchLoading,
    required R Function(Object error) onFetchFailure,
    required R Function(Content content) onRefreshSuccess,
  }) {
    final self = this;
    if (self is _FetchSuccess<Content>) {
      return onFetchSuccess(self.content);
    }
    if (self is _FetchLoading<Content>) {
      return onFetchLoading();
    }
    if (self is _FetchFailure<Content>) {
      return onFetchFailure(self.error);
    }
    if (self is _RefreshSuccess<Content>) {
      return onRefreshSuccess(self.content);
    }
    throw StateError('Unknown type of $self');
  }
}

class _FetchSuccess<Content> extends LoaderPartialStateChange<Content> {
  final Content content;

  const _FetchSuccess(this.content) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FetchSuccess &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() => 'FetchSuccess { content: $content }';
}

class _FetchLoading<Content> extends LoaderPartialStateChange<Content> {
  const _FetchLoading() : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FetchLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'FetchLoading { }';
}

class _FetchFailure<Content> extends LoaderPartialStateChange<Content> {
  final Object error;

  const _FetchFailure(this.error) : super._();

  @override
  String toString() => 'FetchFailure { error: $error }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FetchFailure &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}

class _RefreshSuccess<Content> extends LoaderPartialStateChange<Content> {
  final Content content;

  const _RefreshSuccess(this.content) : super._();

  @override
  String toString() => 'RefreshSuccess { content: $content }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _RefreshSuccess &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;
}
