import 'package:firebase_auth/firebase_auth.dart';
import 'package:puki/src/core/helper/log.dart';
import 'package:puki/src/core/settings/settings.dart';

class PukiAuth {
  // 1. Create a static variable that serves as the singleton _instance of this class.
  static final PukiAuth _instance = PukiAuth._internal();
  // 2. Create a private constructor to prevent the creation of additional instances of this class.
  PukiAuth._internal();
  // 3. Create a factory method that returns the single instance (_instance) of this class.
  factory PukiAuth() => _instance;

  FirebaseAuth? _auth;

  void setInstance(dynamic app) {
    if (PukiSettings().client.useFirebaseAuth == false) return;

    _auth = FirebaseAuth.instanceFor(app: app);

    if (PukiSettings().client.authEmulator != null) {
      _auth!.useAuthEmulator(
        PukiSettings().client.authEmulator!['host'],
        PukiSettings().client.authEmulator!['port'],
      );
      devLog("PukiAuth > setAuthInstance | $app [EMULATOR]");
    } else {
      devLog("PukiAuth > setAuthInstance | $app");
    }
  }

  Future<void> signIn(String email, String password) async {
    if (PukiSettings().client.useFirebaseAuth == false) return;
    await _auth!.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    if (PukiSettings().client.useFirebaseAuth == false) return;
    await _auth!.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    if (PukiSettings().client.useFirebaseAuth == false) return;
    await _auth!.signOut();
  }
}
