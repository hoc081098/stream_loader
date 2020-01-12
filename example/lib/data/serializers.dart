import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:example/data/comment.dart';

part 'serializers.g.dart';

@SerializersFor([Comment])
final Serializers serializers = _$serializers;
final Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
