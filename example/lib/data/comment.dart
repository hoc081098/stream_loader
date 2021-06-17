import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'comment.g.dart';

abstract class Comment implements Built<Comment, CommentBuilder> {
  int get postId;

  int get id;

  String get name;

  String get email;

  String get body;

  Comment._();

  factory Comment([void Function(CommentBuilder) updates]) = _$Comment;

  static Serializer<Comment> get serializer => _$commentSerializer;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith<Comment>(serializer, json)!;

  Map<String, dynamic> toJson() =>
      serializers.serializeWith(serializer, this)! as Map<String, dynamic>;
}
