// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Comment> _$commentSerializer = new _$CommentSerializer();

class _$CommentSerializer implements StructuredSerializer<Comment> {
  @override
  final Iterable<Type> types = const [Comment, _$Comment];
  @override
  final String wireName = 'Comment';

  @override
  Iterable<Object?> serialize(Serializers serializers, Comment object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'postId',
      serializers.serialize(object.postId, specifiedType: const FullType(int)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'email',
      serializers.serialize(object.email,
          specifiedType: const FullType(String)),
      'body',
      serializers.serialize(object.body, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  Comment deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new CommentBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'postId':
          result.postId = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'email':
          result.email = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'body':
          result.body = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$Comment extends Comment {
  @override
  final int postId;
  @override
  final int id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String body;

  factory _$Comment([void Function(CommentBuilder)? updates]) =>
      (new CommentBuilder()..update(updates)).build();

  _$Comment._(
      {required this.postId,
      required this.id,
      required this.name,
      required this.email,
      required this.body})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(postId, 'Comment', 'postId');
    BuiltValueNullFieldError.checkNotNull(id, 'Comment', 'id');
    BuiltValueNullFieldError.checkNotNull(name, 'Comment', 'name');
    BuiltValueNullFieldError.checkNotNull(email, 'Comment', 'email');
    BuiltValueNullFieldError.checkNotNull(body, 'Comment', 'body');
  }

  @override
  Comment rebuild(void Function(CommentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommentBuilder toBuilder() => new CommentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Comment &&
        postId == other.postId &&
        id == other.id &&
        name == other.name &&
        email == other.email &&
        body == other.body;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, postId.hashCode), id.hashCode), name.hashCode),
            email.hashCode),
        body.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Comment')
          ..add('postId', postId)
          ..add('id', id)
          ..add('name', name)
          ..add('email', email)
          ..add('body', body))
        .toString();
  }
}

class CommentBuilder implements Builder<Comment, CommentBuilder> {
  _$Comment? _$v;

  int? _postId;
  int? get postId => _$this._postId;
  set postId(int? postId) => _$this._postId = postId;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  CommentBuilder();

  CommentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _postId = $v.postId;
      _id = $v.id;
      _name = $v.name;
      _email = $v.email;
      _body = $v.body;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Comment other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Comment;
  }

  @override
  void update(void Function(CommentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Comment build() {
    final _$result = _$v ??
        new _$Comment._(
            postId: BuiltValueNullFieldError.checkNotNull(
                postId, 'Comment', 'postId'),
            id: BuiltValueNullFieldError.checkNotNull(id, 'Comment', 'id'),
            name:
                BuiltValueNullFieldError.checkNotNull(name, 'Comment', 'name'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, 'Comment', 'email'),
            body:
                BuiltValueNullFieldError.checkNotNull(body, 'Comment', 'body'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
