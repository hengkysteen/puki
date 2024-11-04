// coverage:ignore-file

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/src/core/settings/settings.dart';
import '../helper/log.dart';
import 'collections/message.dart';

class PukiFirestore {
  static final PukiFirestore _pukiFirestore = PukiFirestore._internal();

  PukiFirestore._internal();

  factory PukiFirestore() {
    return _pukiFirestore;
  }

  late final FirebaseFirestore instance;

  late final MessagesCollection message;

  void setInstance(dynamic app) {
    instance = FirebaseFirestore.instanceFor(app: app!);

    if (PukiSettings.instance.client.firestoreEmulator != null) {
      instance.useFirestoreEmulator(
        PukiSettings.instance.client.firestoreEmulator!['host'],
        PukiSettings.instance.client.firestoreEmulator!['port'],
      );
    }

    message = MessagesCollection(instance);

    devLog("PukiFirestore > setInstance | $app");
  }

  void setTestInstance(FirebaseFirestore testFirestore, {required MessagesCollection mockMessageCollection}) {
    instance = testFirestore;
    message = mockMessageCollection;
  }
}
