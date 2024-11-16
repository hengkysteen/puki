import 'dart:async';
import 'package:puki/puki.dart';
import 'package:puki/src/core/auth/auth.dart';
import 'package:puki/src/core/helper/log.dart';
import 'package:puki/src/core/settings/settings.dart';
import 'package:puki/src/core/user/online_listener.dart';

class PukiUser {
  // 1. Create a static variable that serves as the singleton _instance of this class.
  static final PukiUser _instance = PukiUser._internal();
  // 2. Create a private constructor to prevent the creation of additional instances of this class.
  PukiUser._internal();
  // 3. Create a factory method that returns the single instance (_instance) of this class.
  factory PukiUser() => _instance;

  static PmUser? _currentUser;

  PmUser? get currentUser => _currentUser;

  Future<PmUser?> setCurrentUser(String userId) async {
    devLog("PukiUser > setUser | $userId");
    final user = await Puki.firestore.user.getSingleUser(userId);

    if (user != null) {
      _currentUser = user;
      if (PukiSettings().client.userOnlineStatusListener) {
        OnlineStatusListener().addOnlineStatusListener();
      }
      await setOnline(true);
    }

    return user;
  }

  // Future<void> register({
  //   required String id,
  //   required String name,
  //   required String email,
  //   String avatar = '',
  //   Map<String, dynamic>? userData,
  // }) async {
  //   devLog("PukiUser > register | $name");
  //   final model = PmUser(id: id, name: name, email: email, avatar: avatar, userData: userData);
  //   try {
  //     await PukiAuth().signUp(email, "${id}_$email");
  //     await Puki.firestore.user.createUser(model);
  //     await setCurrentUser(id);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> setup({required String id, required String name, required String email, String avatar = '', Map<String, dynamic>? userData}) async {
    devLog("PukiUser > setup | $name");
    try {
      await PukiAuth().signIn(email, "${id}_$email");
      final user = await setCurrentUser(id);
      if (user == null) {
        final model = PmUser(id: id, name: name, email: email, avatar: avatar, userData: userData);
        await Puki.firestore.user.createUser(model);
        await setCurrentUser(id);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> login({required String id, required String email}) async {
  //   devLog("PukiUser > login | $email");
  //   try {
  //     await PukiAuth().signIn(email, "${id}_$email");
  //     await setCurrentUser(id);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<PmUser> addUser({required String id, String name = '', String email = '', String avatar = '', Map<String, dynamic>? userData}) async {
  //   PmUser? user;

  //   user = await setCurrentUser(id);

  //   if (user == null) {
  //     final model = PmUser(
  //       id: id,
  //       name: name,
  //       email: email,
  //       avatar: avatar,
  //       userData: userData,
  //     );

  //     await Puki.firestore.user.createUser(model);

  //     user = await setCurrentUser(id);
  //   }

  //   devLog("PukiUser > addUser | ${user!.name}, Id = ${user.id} ");

  //   return user;
  // }

  Future<void> setOnline(bool status) async {
    if (currentUser == null) return;
    if (PukiSettings().client.userOnlineStatusListener == false) return;
    await Puki.firestore.user.setOnlineStatus(userId: currentUser!.id, status: status);
    devLog("PukiUser > setOnline | $status [${currentUser!.firstName} is ${status ? 'Online' : 'Offline'}]");
  }

  Future<void> setTyping(bool status, String roomId) async {
    if (currentUser == null) return;
    await Puki.firestore.user.setTypingStatus(userId: currentUser!.id, status: status, roomId: roomId);
    devLog("PukiUser > setTyping | $status [${currentUser!.firstName} is ${status ? 'Online' : 'Offline'}]");
  }

  Future<void> logout() async {
    devLog("PukiUser > logout");
    await setOnline(false);

    if (PukiSettings().client.userOnlineStatusListener) {
      OnlineStatusListener().removeOnlineStatusListener();
    }
    _currentUser = null;

    // await _auth!.signOut();
    await PukiAuth().signOut();
  }

  // setAuthInstance(dynamic app) {
  //   if (PukiSettings().client.useFirebaseAuth == false) return;
  //   _auth = FirebaseAuth.instanceFor(app: app);

  //   if (PukiSettings().client.authEmulator != null) {
  //     _auth!.useAuthEmulator(
  //       PukiSettings().client.authEmulator!['host'],
  //       PukiSettings().client.authEmulator!['port'],
  //     );
  //     devLog("PukiUser > setAuthInstance | $app [EMULATOR]");
  //   } else {
  //     devLog("PukiUser > setAuthInstance | $app");
  //   }
  // }
}
