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
        final user = Db.getByEmail(FirebaseAuth.instance.currentUser!.email!);
        if (user != null) {
          _user = User.fromJson(user);
        }
      }
    } else {
      _user = await Storage.getUser();
    }
    print("user = $user");
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
    }

    // start puki package
    await Puki.user.setup(id: _user!.id, email: _user!.email, name: _user!.name, avatar: _user!.avatar);
    // end puki package
  }

  Future<void> register(String email, String password) async {
    final userMap = Db.getByEmail(email);

    if (userMap == null) throw Exception("no user with email on dummy database");

    if (Config.exampleType == ExampleType.withFirebaseAuth) {
      //  ExampleType.withFirebaseAuth

      final auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await auth.user?.updateProfile(displayName: userMap['name'], photoURL: userMap['avatar']);

      _user = User.fromJson(userMap);
    } else {
      // ExampleType.withoutFirebaseAuth

      _user = User.fromJson(userMap);
    }

    // start puki package
    await Puki.user.setup(id: _user!.id, email: _user!.email, name: _user!.name, avatar: _user!.avatar);
    // end puki package
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