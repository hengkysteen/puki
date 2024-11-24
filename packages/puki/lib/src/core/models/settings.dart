// coverage:ignore-file
import 'package:puki/src/core/models/input_type.dart';

class PmSettings {
  /// set to `false` if your already use firebase auth
  final bool useFirebaseAuth;

  /// Firestore Emulator eg :  {"host": "localhost", "port": 8080},
  final Map<String, dynamic>? firestoreEmulator;

  /// Firebase Auth Emulator eg :  {"host": "localhost", "port": 9099},
  final Map<String, dynamic>? authEmulator;

  /// Firestore Collection Prefix. default `puki_`
  final String firestorePrefix;

  /// User online/offline listener
  final bool userOnlineStatusListener;

  /// Online status Debounce Duration in milisecond. default 2000 ,  minimum 1000
  final int onlineStatusDebounceDuration;

  final List<PmInputType> inputTypes;

  /// Developer log
  final bool showDevLog;
  PmSettings({
    this.useFirebaseAuth = true,
    this.showDevLog = true,
    this.userOnlineStatusListener = true,
    this.firestoreEmulator,
    this.authEmulator,
    this.firestorePrefix = "",
    this.onlineStatusDebounceDuration = 2000,
    this.inputTypes = const [],
  })  : assert(onlineStatusDebounceDuration >= 1000),
        assert(useFirebaseAuth || authEmulator == null, 'authEmulator must be null if useFirebaseAuth is false');
}
