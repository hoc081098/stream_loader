import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'comment.dart';

part 'serializers.g.dart';

const commentsBuiltList = FullType(
  BuiltList,
  [FullType(Comment)],
);

@SerializersFor([Comment])
final Serializers _serializers = _$serializers;
final Serializers serializers = (_serializers.toBuilder()
      ..addBuilderFactory(
        commentsBuiltList,
        () => ListBuilder<Comment>(),
      )
      ..addPlugin(StandardJsonPlugin()))
    .build();
