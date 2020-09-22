// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loader_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LoaderState<Content> extends LoaderState<Content> {
  @override
  final Content content;
  @override
  final bool isLoading;
  @override
  final Object error;

  factory _$LoaderState([void Function(LoaderStateBuilder<Content>) updates]) =>
      (new LoaderStateBuilder<Content>()..update(updates)).build();

  _$LoaderState._({this.content, this.isLoading, this.error}) : super._() {
    if (isLoading == null) {
      throw new BuiltValueNullFieldError('LoaderState', 'isLoading');
    }
    if (Content == dynamic) {
      throw new BuiltValueMissingGenericsError('LoaderState', 'Content');
    }
  }

  @override
  LoaderState<Content> rebuild(
          void Function(LoaderStateBuilder<Content>) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LoaderStateBuilder<Content> toBuilder() =>
      new LoaderStateBuilder<Content>()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoaderState &&
        content == other.content &&
        isLoading == other.isLoading &&
        error == other.error;
  }

  int __hashCode;
  @override
  int get hashCode {
    return __hashCode ??= $jf(
        $jc($jc($jc(0, content.hashCode), isLoading.hashCode), error.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('LoaderState')
          ..add('content', content)
          ..add('isLoading', isLoading)
          ..add('error', error))
        .toString();
  }
}

class LoaderStateBuilder<Content>
    implements Builder<LoaderState<Content>, LoaderStateBuilder<Content>> {
  _$LoaderState<Content> _$v;

  Content _content;
  Content get content => _$this._content;
  set content(Content content) => _$this._content = content;

  bool _isLoading;
  bool get isLoading => _$this._isLoading;
  set isLoading(bool isLoading) => _$this._isLoading = isLoading;

  Object _error;
  Object get error => _$this._error;
  set error(Object error) => _$this._error = error;

  LoaderStateBuilder();

  LoaderStateBuilder<Content> get _$this {
    if (_$v != null) {
      _content = _$v.content;
      _isLoading = _$v.isLoading;
      _error = _$v.error;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LoaderState<Content> other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$LoaderState<Content>;
  }

  @override
  void update(void Function(LoaderStateBuilder<Content>) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$LoaderState<Content> build() {
    final _$result = _$v ??
        new _$LoaderState<Content>._(
            content: content, isLoading: isLoading, error: error);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new,must_be_immutable,public_member_api_docs
