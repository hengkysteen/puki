// coverage:ignore-file
import 'package:puki/src/core/helper/fields.dart';
import 'package:puki/src/core/models/index.dart';

class PukiCoreSettings {
  static final PukiCoreSettings _instance = PukiCoreSettings._internal();

  PukiCoreSettings._internal();

  factory PukiCoreSettings() => _instance;

  static late final PmSettings _settings;

  PmSettings get settings => _settings;

  void setClientSettings(PmSettings? settings) {
    _settings = settings ?? PmSettings();
  }

  String getCollectionPath(String collectionName) {
    String prefix = settings.firestorePrefix.isEmpty ? F.FIRESTORE_COLLECTION_PREFIX : settings.firestorePrefix;
    return "$prefix$collectionName";
  }
}
