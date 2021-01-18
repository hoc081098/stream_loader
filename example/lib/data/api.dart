import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'comment.dart';
import 'serializers.dart';

class Api {
  static const commentsUrl = 'https://jsonplaceholder.typicode.com/comments';

  final http.Client _client;

  const Api(this._client);

  Stream<BuiltList<Comment>> getComments() async* {
    _logRequest(commentsUrl);

    final response = await _client.get(commentsUrl);
    final json = jsonDecode(response.body);

    yield serializers.deserialize(json, specifiedType: commentsBuiltList)
        as BuiltList<Comment>;
  }

  Stream<Comment> getCommentBy({@required int id}) async* {
    if (id == null) {
      throw ArgumentError.notNull('id');
    }
    _logRequest('$commentsUrl/$id');

    final response = await _client.get('$commentsUrl/$id');
    final json = jsonDecode(response.body);

    yield Comment.fromJson(json);
  }

  void dispose() => _client.close();

  void _logRequest(String url) => print('--> GET $url');
}
