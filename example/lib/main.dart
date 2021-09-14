import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:http/http.dart' as http;

import 'data/api.dart';
import 'home_page.dart';

void main() {
  final api = Api(http.Client());
  runApp(
    Provider<Api>.value(
      api,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
