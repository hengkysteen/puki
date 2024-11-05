// coverage:ignore-file

import 'package:puki/src/core/helper/fields.dart';
import 'package:puki/src/core/models/index.dart';

class PukiSettings {
  static final PukiSettings _instance = PukiSettings._internal();

  PukiSettings._internal();

  static PukiSettings get instance => _instance;

  PmSetting client = PmSetting();

  void setClientSettings(PmSetting? settings) {
    if (settings == null) return;
    client = settings;
  }

  String getCollectionPath(String collectionName) {
    String prefix = client.firestorePrefix.isEmpty ? F.FIRESTORE_COLLECTION_PREFIX : client.firestorePrefix;
    return "$prefix$collectionName";
  }
}
