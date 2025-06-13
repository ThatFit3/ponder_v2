import 'package:flutter/material.dart';
import 'package:ponder_app/root.dart';

void main() {
  runApp(const MyApp());
}

List<String> keys = ["GQHR6ZQTTHYCV08L"];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: RootPage());
  }
}
