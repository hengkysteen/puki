import 'package:firebase_auth/firebase_auth.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/config.dart';
import 'package:puki_example/services/db.dart';
import 'package:puki_example/services/storage.dart';

class UserControl {
  static final UserControl _instance = UserControl._internal();

  UserControl._internal();

  factory UserControl() => _instance;

  static User? _user;

  User? get user => _user;

  Future<void> getCurrentUser() async {
    if (Config.exampleType == ExampleType.withFirebaseAuth) {
      if (FirebaseAuth.instance.currentUser != null) {
        final userMap = Db.getByEmail(FirebaseAuth.instance.currentUser!.email!);
        if (userMap != null) {
          _user = User.fromJson(userMap);
        }
      }
    } else {
      final user = await Storage.getUser();
      if (user != null) {
        final userMap = Db.getByEmail(user.email);
        if (userMap != null) {
          _user = User.fromJson(userMap);
        }
      }
    }
    if (_user != null) {
      await Puki.setUser(_user!.id);
    }
  }

  Future<void> login(String email, String password) async {
    final userDb = Db.getByEmail(email);
    if (userDb == null) throw Exception("no user with email on dummy database");
    if (Config.exampleType == ExampleType.withFirebaseAuth) {
      //  ExampleType.withFirebaseAuth
      final auth = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final userMap = Db.getByEmail(auth.user!.email!);
      _user = User.fromJson(userMap!);
    } else {
      // ExampleType.withoutFirebaseAuth
      final userMap = Db.getByEmail(email);
      _user = User.fromJson(userMap!);
      Storage.saveUser(_user!);
    }
    // start puki package
    await Puki.setupUser(id: _user!.id, email: _user!.email, name: _user!.name, avatar: _user!.avatar, isLogin: true);
    // end puki package
  }

  Future<void> register(String email, String password) async {
    final userMap = Db.getByEmail(email);
    if (userMap == null) throw Exception("no user with email on dummy database");

    final userModel = User.fromJson(userMap);

    if (Config.exampleType == ExampleType.withFirebaseAuth) {
      //  ExampleType.withFirebaseAuth
      final auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await auth.user?.updateProfile(displayName: userMap['name'], photoURL: userMap['avatar']);

      await Puki.setupUser(id: userModel.id, email: userModel.email, name: userModel.name, avatar: userModel.avatar, isLogin: false);
    } else {
      // ExampleType.withoutFirebaseAuth

      await Puki.setupUser(id: userModel.id, email: userModel.email, name: userModel.name, avatar: userModel.avatar, isLogin: false);
      Storage.saveUser(userModel);
    }
    _user = userModel;

    print("user = ${user?.toJson()}");
  }

  Future<void> logout() async {
    await Puki.logout();
    if (Config.exampleType == ExampleType.withFirebaseAuth) {
      await FirebaseAuth.instance.signOut();
    } else {
      Storage.clearUser();
    }
    _user = null;
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  User({required this.id, required this.name, required this.email, this.avatar = ""});
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }
}
