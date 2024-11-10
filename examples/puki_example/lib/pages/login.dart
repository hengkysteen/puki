import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/pages/home.dart';
import 'package:puki_example/services/storage.dart';
import 'package:puki_example/services/users.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    Users.dummy.sort((a, b) => a['name'].compareTo(b['name']));
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: Users.dummy.map((e) {
              return ListTile(
                title: Text(e['name']),
                subtitle: Text(e['email']),
                trailing: TextButton(
                  onPressed: () async => await setUser(context, e, isLogin: true),
                  child: Text("Login"),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> setUser(BuildContext context, Map<String, dynamic> user, {bool isLogin = true}) async {
    Users.setCurrentUser(user);
    await Storage.saveUser(user);
    await Puki.user.setup(id: user['id'], name: user['name'], email: user['email'], avatar: user['avatar']);
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(user: user)));
  }
}
