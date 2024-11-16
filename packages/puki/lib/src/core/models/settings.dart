// coverage:ignore-file

class PmSetting {
  final bool useFirebaseAuth;

  /// Firebase Emulator
  ///
  /// eg :  {"host": "localhost", "port": 8080},
  final Map<String, dynamic>? firestoreEmulator;

  /// Firebase Auth
  ///
  /// eg :  {"host": "localhost", "port": 9099},
  final Map<String, dynamic>? authEmulator;

  /// Firestore Collection Prefix
  ///
  /// default `puki_`
  final String firestorePrefix;

  /// User online/offline listener
  final bool userOnlineStatusListener;

  /// Online status Debounce Duration in milisecond
  ///
  /// default 2000 ,  minimum 1000
  final int onlineStatusDebounceDuration;

  /// Developer log
  final bool showDevLog;

  PmSetting({
    this.useFirebaseAuth = true,
    this.showDevLog = true,
    this.userOnlineStatusListener = true,
    this.firestoreEmulator,
    this.authEmulator,
    this.firestorePrefix = "",
    this.onlineStatusDebounceDuration = 2000,
  })  : assert(onlineStatusDebounceDuration >= 1000),
        assert(useFirebaseAuth || authEmulator == null, 'authEmulator must be null if useFirebaseAuth is false');
}
