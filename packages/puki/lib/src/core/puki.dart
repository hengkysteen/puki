import 'package:puki/src/core/helper/log.dart';
import 'package:puki/src/core/settings/settings.dart';
import 'firestore/firestore.dart';
import 'models/settings.dart';

class Puki {
  static final Puki _instance = Puki._internal();

  static Puki get instance => _instance;

  Puki._internal();

  static dynamic app;

  static final PukiFirestore firestore = PukiFirestore();

  // Metode untuk menginisialisasi
  static Future<void> initialize({required dynamic firebaseApp, PmSetting? settings}) async {
    PukiSettings.instance.setClientSettings(settings);
    app = firebaseApp;
    devLog("initialize");
    firestore.setInstance(app);
  }
}
