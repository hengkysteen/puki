// coverage:ignore-file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/src/core/auth/auth.dart';
import 'package:puki/src/core/firestore/collections/room.dart';
import 'package:puki/src/core/helper/log.dart';
import 'package:puki/src/core/settings/settings.dart';
import 'package:puki/src/core/user/user.dart';
import 'firestore/collections/message.dart';
import 'firestore/collections/user.dart';
import 'firestore/firestore.dart';
import 'models/settings.dart';

class PukiCore {
  // 1. Create a static variable that serves as the singleton _instance of this class.
  static final PukiCore _instance = PukiCore._internal();
  // 2. Create a private constructor to prevent the creation of additional instances of this class.
  PukiCore._internal();
  // 3. Create a factory method that returns the single instance (_instance) of this class.
  factory PukiCore() => _instance;

  static dynamic app;

  static final PukiFirestore firestore = PukiFirestore();

  static final PukiUser user = PukiUser();

  static final PukiCoreSettings settings = PukiCoreSettings();

  static Future<void> initialize({required dynamic firebaseApp, PmSettings? settings}) async {
    app = firebaseApp;
    PukiCore.settings.setClientSettings(settings);
    devLog("Puki > initialize");
    firestore.setInstance(app);
    PukiAuth().setInstance(app);
  }

  static void initializeTest({
    required FirebaseFirestore mockFirestore,
    required MessagesCollection mockMessageCollection,
    required UsersCollection mockUserCollection,
    required RoomsCollection mockRoomCollection,
    PmSettings? mockSettings,
  }) {
    PukiCore.settings.setClientSettings(mockSettings);
    firestore.setTestInstance(
      testFirestore: mockFirestore,
      mockMessage: mockMessageCollection,
      mockUser: mockUserCollection,
      mockRoom: mockRoomCollection,
    );
  }
}
