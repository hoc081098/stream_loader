import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:http/http.dart' as http;

import 'data/api.dart';
import 'home_page.dart';

void main() {
  final api = Api(http.Client());
  runApp(
    Provider<Api>(
      child: MyApp(),
      value: api,
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
