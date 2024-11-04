import 'package:puki/src/core/helper/fields.dart';
import 'package:puki/src/core/models/index.dart';

class PukiSettings {
  static final PukiSettings _instance = PukiSettings._internal();

  // Konstruktor privat
  PukiSettings._internal();

  // Metode untuk mendapatkan instance singleton
  static PukiSettings get instance => _instance;

  PmSetting client = PmSetting();

  // Metode untuk mengatur client settings
  void setClientSettings(PmSetting? settings) {
    if (settings == null) return;
    client = settings;
  }

  // Metode untuk mendapatkan collection path
  String getCollectionPath(String collectionName) {
    String prefix = client.firestorePrefix.isEmpty ? F.FIRESTORE_COLLECTION_PREFIX : client.firestorePrefix;
    return "$prefix$collectionName";
  }
}
