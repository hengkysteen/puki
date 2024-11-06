// coverage:ignore-file

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/src/core/helper/log.dart';
import 'package:puki/src/core/settings/settings.dart';
import 'firestore/collections/message.dart';
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
    app = firebaseApp;
    PukiSettings.instance.setClientSettings(settings);
    devLog("initialize");
    firestore.setInstance(app);
  }

  static void initializeTest({required FirebaseFirestore mockFirestore, required MessagesCollection mockMessageCollection, required}) {
    firestore.setTestInstance(mockFirestore, mockMessageCollection: mockMessageCollection);
  }
}
