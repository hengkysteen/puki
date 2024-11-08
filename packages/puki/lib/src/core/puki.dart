// coverage:ignore-file

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/src/core/firestore/collections/room.dart';
import 'package:puki/src/core/helper/log.dart';
import 'package:puki/src/core/settings/settings.dart';
import 'package:puki/src/core/user/user.dart';
import 'firestore/collections/message.dart';
import 'firestore/collections/user.dart';
import 'firestore/firestore.dart';
import 'models/settings.dart';

class Puki {
  static final Puki _instance = Puki._internal();

  static Puki get instance => _instance;

  Puki._internal();

  static dynamic app;

  static final PukiFirestore firestore = PukiFirestore();
  static final PukiUser user = PukiUser();

  static Future<void> initialize({required dynamic firebaseApp, PmSetting? settings}) async {
    app = firebaseApp;
    PukiSettings().setClientSettings(settings);
    devLog("Puki > initialize");
    firestore.setInstance(app);
  }

  static void initializeTest({
    required FirebaseFirestore mockFirestore,
    required MessagesCollection mockMessageCollection,
    required UsersCollection mockUserCollection,
    required RoomsCollection mockRoomCollection,
    PmSetting? mockSettings,
  }) {
    PukiSettings().setClientSettings(mockSettings);
    firestore.setTestInstance(
      testFirestore: mockFirestore,
      mockMessage: mockMessageCollection,
      mockUser: mockUserCollection,
      mockRoom: mockRoomCollection,
    );
  }
}
