import 'package:example/data/api.dart';
import 'package:example/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  var api = Api(http.Client());
  runApp(
    Provider<Api>(
      child: MyApp(),
      value: api,
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
