import 'package:flutter/material.dart';
import 'package:puki_example/home.dart';
import 'package:puki_example/dummy_users.dart';
import 'package:puki_example/storage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    Dummy.users.sort((a, b) => a['name'].compareTo(b['name']));
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: Dummy.users.map((e) {
              return ListTile(
                  title: Text(e['name']),
                  subtitle: Text(e['email']),
                  trailing: SizedBox(
                    width: 170,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () => setUser(context, e, isLogin: true),
                          child: Text("Login"),
                        ),
                      ],
                    ),
                  ));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> setUser(BuildContext context, Map<String, dynamic> user, {bool isLogin = true}) async {
    await Storage.saveUser(user);
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(user: user)));
  }
}
