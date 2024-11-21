import 'package:flutter/material.dart';
import 'package:puki_example/services/user.dart';
import 'home.dart';
import 'login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _isLoading = false;

  void getCurrentUser() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 1));

    await UserControl().getCurrentUser();


    if (UserControl().user == null) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
    }
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _isLoading ? CircularProgressIndicator() : SizedBox()),
    );
  }
}
