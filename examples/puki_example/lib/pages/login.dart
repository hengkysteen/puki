import 'package:flutter/material.dart';
import 'package:puki_example/widgets/common.dart';

import '../services/db.dart';
import '../services/user.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: Db.users.map((user) {
                    return ListTile(
                        title: Text(user['name']),
                        subtitle: Text(user['email']),
                        trailing: SizedBox(
                          width: 170,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () => login(context, user),
                                child: Text("Login"),
                              ),
                              TextButton(
                                onPressed: () => register(context, user),
                                child: Text("Register"),
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

  Future<void> login(BuildContext context, Map<String, dynamic> user) async {
    setState(() {
      _loading = true;
    });

    try {
      await UserControl().login(user['email'], user['password']);
      if (!context.mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, e.toString());
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> register(BuildContext context, Map<String, dynamic> user) async {
    setState(() {
      _loading = true;
    });

    try {
      await UserControl().register(user['email'], user['password']);
      if (!context.mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, e.toString());
    }

    setState(() {
      _loading = false;
    });
  }
}
