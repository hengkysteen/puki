import 'package:puki/puki.dart';
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

  void _setCurrentUser(PmUser user) {
    _currentUser = user;
  }

  Future<PmUser> setup({required String id, String name = '', String email = '', String avatar = '', Map<String, dynamic>? userData}) async {
    PmUser? user;
    user = await Puki.firestore.user.getSingleUser(id);
    if (user == null) {
      final model = PmUser(
        id: id,
        name: name,
        email: email,
        avatar: avatar,
        userData: userData,
      );
      await Puki.firestore.user.createUser(model);
      user = await Puki.firestore.user.getSingleUser(model.id);
    }
    _setCurrentUser(user!);
    devLog("PukiUser > setup | ${currentUser!.name}, Id = ${currentUser!.id} ");
    if (PukiSettings().client.userOnlineStatusListener) {
      OnlineStatusListener().addOnlineStatusListener();
    }
    await setOnline(true);
    return currentUser!;
  }

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
  }
}
