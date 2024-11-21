import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/config.dart';
import 'package:puki_example/firebase_options.dart';
import 'package:puki_example/pages/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late FirebaseApp app;

  app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (Config.isDevMode == true) {
    await FirebaseStorage.instance.useStorageEmulator("localhost", 9199);
    await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
  }

  final settings = PmSetting(
    useFirebaseAuth: Config.exampleType == ExampleType.withFirebaseAuth ? false : true,
    showDevLog: true,
    userOnlineStatusListener: true,
    firestoreEmulator: Config.isDevMode ? {"host": "localhost", "port": 8080} : null,
  );

  await Puki.initialize(firebaseApp: app, settings: settings);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      home: Splash(),
    ),
  );
}
