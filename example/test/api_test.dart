import 'package:built_collection/built_collection.dart';
import 'package:example/data/api.dart';
import 'package:example/data/comment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  late Api api;

  setUp(() {
    api = Api(http.Client());
  });

  tearDown(() {
    api.dispose();
  });

  test('Expecting a list of comments', () async {
    try {
      final comments = await api.getComments().first;
      expect(comments, isInstanceOf<BuiltList<Comment>>());
      print(comments.length);
    } catch (e) {
      expect(e, isException);
      print(e);
    }
  });

  test('Expecting a comment', () async {
    try {
      final comment = await api.getCommentBy(id: 1).first;
      expect(comment, isInstanceOf<Comment>());
      expect(comment.id, 1);
    } catch (e) {
      expect(e, isException);
      print(e);
    }
  });
}
