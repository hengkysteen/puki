import 'package:flutter/material.dart';
import 'package:puki_example/pages/splash.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        primarySwatch: Colors.purple,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
      ),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}
