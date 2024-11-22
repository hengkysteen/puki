// coverage:ignore-file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/core/firestore/collections/room.dart';
import 'package:puki/src/core/firestore/collections/user.dart';
import '../helper/log.dart';
import 'collections/message.dart';

class PukiFirestore {
  static final PukiFirestore _pukiFirestore = PukiFirestore._internal();

  PukiFirestore._internal();

  factory PukiFirestore() => _pukiFirestore;

  late final FirebaseFirestore instance;

  late final MessagesCollection message;

  late final UsersCollection user;

  late final RoomsCollection room;

  void setInstance(dynamic app) async {
    instance = FirebaseFirestore.instanceFor(app: app!);

    if (PukiCore.settings.settings.firestoreEmulator != null) {
      instance.useFirestoreEmulator(
        PukiCore.settings.settings.firestoreEmulator!['host'],
        PukiCore.settings.settings.firestoreEmulator!['port'],
      );
      devLog("PukiFirestore > setInstance | $app [EMULATOR]");
    } else {
      devLog("PukiFirestore > setInstance | $app");
    }

    message = MessagesCollection(instance);
    user = UsersCollection(instance);
    room = RoomsCollection(instance);
  }

  void setTestInstance({
    required FirebaseFirestore testFirestore,
    required MessagesCollection mockMessage,
    required UsersCollection mockUser,
    required RoomsCollection mockRoom,
  }) {
    instance = testFirestore;
    message = mockMessage;
    user = mockUser;
    room = mockRoom;
  }
}
