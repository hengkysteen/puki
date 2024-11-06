import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/firebase_options.dart';
import 'app.dart';

class Config {
  static const bool isDevMode = true;
  static const String homePage = "CORE";
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late FirebaseApp app;

  app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final settings = PmSetting(
    showDevLog: true,
    onlineStatusListener: false,
    firestoreEmulator: Config.isDevMode ? {"host": "localhost", "port": 8080} : null,
  );

  await Puki.initialize(firebaseApp: app, settings: settings);

  runApp(const App());
}
