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

  final firestoreEmulator = Config.isDevMode ? {"host": "localhost", "port": 8080} : null;
  final useFirebaseAuth = Config.exampleType == ExampleType.withFirebaseAuth ? false : true;

  await Puki.initialize(
    firebaseApp: app,
    settings: PmSettings(
      useFirebaseAuth: useFirebaseAuth,
      showDevLog: true,
      userOnlineStatusListener: true,
      firestoreEmulator: firestoreEmulator,
    ),
  );
  

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      home: Splash(),
    ),
  );
}
