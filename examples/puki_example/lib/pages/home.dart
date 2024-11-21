import 'package:flutter/material.dart';
import 'package:puki/puki_ui.dart';
import 'package:puki_example/pages/login.dart';
import 'package:puki_example/pages/message.dart';
import 'package:puki_example/services/user.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = false;

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  Future<void> _logout(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    await Future.delayed(Duration(seconds: 1));
    await UserControl().logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () async => await _logout(context),
          icon: Icon(Icons.logout),
        ),
        title: Text("Hi, ${UserControl().user!.name} "),
        actions: [
          PukiUnreadBadge(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Message()));
            },
          ),
          SizedBox(width: 8)
        ],
      ),
    );
  }
}
