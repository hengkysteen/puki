import 'package:flutter/material.dart';
import 'package:puki_example/config.dart';
import 'package:puki_example/src/core/home.dart';
import 'package:puki_example/src/ui/home.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Config.homePage == "CORE" ? HomeCore() : Home(),
    );
  }
}
