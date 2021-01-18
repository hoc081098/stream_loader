part of 'loader_state.dart';

// ignore_for_file: hash_and_equals, public_member_api_docs, must_be_immutable

class _$LoaderState<Content extends Object> extends LoaderState<Content> {
  @override
  final Content? content;
  @override
  final bool isLoading;
  @override
  final Object? error;

  factory _$LoaderState(
          [void Function(LoaderStateBuilder<Content>)? updates]) =>
      (LoaderStateBuilder<Content>()..update(updates)).build();

  _$LoaderState._({this.content, required this.isLoading, this.error})
      : super._() {
    ArgumentError.checkNotNull(isLoading, 'isLoading');
    if (Content == dynamic) {
      throw StateError(
          'Tried to construct class "LoaderState" with missing or dynamic '
          'type argument "Content". All type arguments must be specified.');
    }
  }

  @override
  LoaderState<Content> rebuild(
          void Function(LoaderStateBuilder<Content>) updates) =>
      (toBuilder()..update(updates)).build();

  LoaderStateBuilder<Content> toBuilder() =>
      LoaderStateBuilder<Content>()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoaderState &&
        content == other.content &&
        isLoading == other.isLoading &&
        error == other.error;
  }

  int? __hashCode;

  @override
  int get hashCode {
    return __hashCode ??= _$jf(
      _$jc(
        _$jc(
          _$jc(
            0,
            content.hashCode,
          ),
          isLoading.hashCode,
        ),
        error.hashCode,
      ),
    );
  }

  @override
  String toString() {
    return 'LoaderState {\n'
        '  isLoading=$isLoading,\n'
        '  error=$error,\n'
        '  content=$content,\n'
        '}';
  }
}

class LoaderStateBuilder<Content extends Object> {
  _$LoaderState<Content>? _$v;

  Content? _content;

  Content? get content => _$this._content;

  set content(Content? content) => _$this._content = content;

  bool? _isLoading;

  bool? get isLoading => _$this._isLoading;

  set isLoading(bool? isLoading) => _$this._isLoading = isLoading;

  Object? _error;

  Object? get error => _$this._error;

  set error(Object? error) => _$this._error = error;

  LoaderStateBuilder();

  LoaderStateBuilder<Content> get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _isLoading = $v.isLoading;
      _error = $v.error;
      _$v = null;
    }
    return this;
  }

  void replace(LoaderState<Content> other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$LoaderState<Content>;
  }

  void update(void Function(LoaderStateBuilder<Content>)? updates) {
    if (updates != null) updates(this);
  }

  _$LoaderState<Content> build() {
    final _$result = _$v ??
        _$LoaderState<Content>._(
          content: content,
          isLoading: ArgumentError.checkNotNull(isLoading, 'isLoading'),
          error: error,
        );
    replace(_$result);
    return _$result;
  }
}

/// For use by generated code in calculating hash codes. Do not use directly.
int _$jc(int hash, int value) {
  // Jenkins hash "combine".
  hash = 0x1fffffff & (hash + value);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

/// For use by generated code in calculating hash codes. Do not use directly.
int _$jf(int hash) {
  // Jenkins hash "finish".
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}
