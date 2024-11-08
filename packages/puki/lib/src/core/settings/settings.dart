// coverage:ignore-file

import 'package:puki/src/core/helper/fields.dart';
import 'package:puki/src/core/models/index.dart';

class PukiSettings {
  static final PukiSettings _instance = PukiSettings._internal();

  PukiSettings._internal();

  factory PukiSettings() => _instance;

  late final PmSetting client;

  void setClientSettings(PmSetting? settings) {
    client = settings ?? PmSetting();
  }

  String getCollectionPath(String collectionName) {
    String prefix = client.firestorePrefix.isEmpty ? F.FIRESTORE_COLLECTION_PREFIX : client.firestorePrefix;
    return "$prefix$collectionName";
  }
}
