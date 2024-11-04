// coverage:ignore-file

class PmSetting {
  /// Firebase Emulator
  ///
  /// eg :  {"host": "localhost", "port": 8080},
  Map<String, dynamic>? firestoreEmulator;

  /// Firestore Collection Prefix
  ///
  /// default `puki_`
  String firestorePrefix;

  ///  User online/offline listener
  bool onlineStatusListener;

  /// Online status Debounce Duration in milisecond
  ///
  /// default 2000 ,  minimum 1000
  int onlineStatusDebounceDuration;

  /// Developer log
  bool showDevLog;

  PmSetting({
    this.showDevLog = true,
    this.onlineStatusListener = true,
    this.firestoreEmulator,
    this.firestorePrefix = "",
    this.onlineStatusDebounceDuration = 2000,
  }) : assert(onlineStatusDebounceDuration >= 1000);
}
