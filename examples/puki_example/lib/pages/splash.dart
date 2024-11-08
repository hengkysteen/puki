import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/pages/home.dart';
import 'package:puki_example/pages/login.dart';
import 'package:puki_example/services/storage.dart';
import 'package:puki_example/services/users.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isLoading = false;

  @override
  void initState() {
    setup();
    super.initState();
  }

  setup() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    final user = await Storage.getUser();
    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    } else {
      Users.setCurrentUser(user);

      /// Puki Package
      await Puki.user.setup(id: user['id']);

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(user: user)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Center(child: CircularProgressIndicator()) : Center(),
    );
  }
}
