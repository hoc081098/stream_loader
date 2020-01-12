import 'dart:convert';

import 'package:example/data/comment.dart';
import 'package:example/data/serializers.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';

class Api {
  final http.Client _client;

  const Api(this._client);

  Stream<BuiltList<Comment>> getComments() async* {
    var response =
        await _client.get('https://jsonplaceholder.typicode.com/comments');
    var json = jsonDecode(response.body) as List;
    var comments = json
        .cast<Map<String, dynamic>>()
        .map((json) =>
            standardSerializers.deserializeWith(Comment.serializer, json))
        .toList();
    yield BuiltList.of(comments);
  }

  Stream<Comment> getCommentBy({@required int id}) async* {
    if (id == null) {
      throw ArgumentError.notNull('id');
    }
    var response =
        await _client.get('https://jsonplaceholder.typicode.com/comments/$id');
    var json = jsonDecode(response.body);
    yield standardSerializers.deserializeWith(Comment.serializer, json);
  }

  void dispose() => _client.close();
}
