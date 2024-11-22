library puki;

import 'package:puki/src/core/core.dart';
import 'package:puki/src/core/firestore/firestore.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'src/core/models/index.dart';

export 'src/core/models/index.dart';
export 'src/ui/ui.dart';

class Puki {
  // 1. Create a static variable that serves as the singleton _instance of this class.
  static final Puki _instance = Puki._internal();
  // 2. Create a private constructor to prevent the creation of additional instances of this class.
  Puki._internal();
  // 3. Create a factory method that returns the single instance (_instance) of this class.
  factory Puki() => _instance;

  // CORE //
  static Future<void> initialize({required dynamic firebaseApp, PmSettings? settings}) async {
    await PukiCore.initialize(firebaseApp: firebaseApp, settings: settings);
  }

  static PukiFirestore get firestore => PukiCore.firestore;

  // USER //

  static Future<void> setupUser({
    required String id,
    required String name,
    required String email,
    String avatar = '',
    Map<String, dynamic>? userData,
    bool isLogin = true,
  }) async {
    await PukiCore.user.setup(id: id, name: name, email: email, avatar: avatar, userData: userData, isLogin: isLogin);
  }

  static Future<void> setUser(String userId) async => await PukiCore.user.setCurrentUser(userId);

  static Future<void> logout() async => await PukiCore.user.logout();

  // MESSAGE //
  static Future<void> sendCustomMessage({required PmRoom room, required PmContent content}) async {
    await Controller.message.sendMessage(room: room, content: content);
  }
}
