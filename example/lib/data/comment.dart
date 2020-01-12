import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'comment.g.dart';

abstract class Comment implements Built<Comment, CommentBuilder> {
  static Serializer<Comment> get serializer => _$commentSerializer;

  int get postId;

  int get id;

  String get name;

  String get email;

  String get body;

  Comment._();

  factory Comment([void Function(CommentBuilder) updates]) = _$Comment;
}
