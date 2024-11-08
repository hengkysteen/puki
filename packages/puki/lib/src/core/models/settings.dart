// coverage:ignore-file

class PmSetting {
  /// Firebase Emulator
  ///
  /// eg :  {"host": "localhost", "port": 8080},
  final Map<String, dynamic>? firestoreEmulator;

  /// Firestore Collection Prefix
  ///
  /// default `puki_`
  final String firestorePrefix;

  ///  User online/offline listener
  final bool userOnlineStatusListener;

  /// Online status Debounce Duration in milisecond
  ///
  /// default 2000 ,  minimum 1000
  final int onlineStatusDebounceDuration;

  /// Developer log
  final bool showDevLog;

  PmSetting({
    this.showDevLog = true,
    this.userOnlineStatusListener = true,
    this.firestoreEmulator,
    this.firestorePrefix = "",
    this.onlineStatusDebounceDuration = 2000,
  }) : assert(onlineStatusDebounceDuration >= 1000);
}
