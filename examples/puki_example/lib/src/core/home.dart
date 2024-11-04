import 'package:flutter/material.dart';

class HomeCore extends StatefulWidget {
  const HomeCore({super.key});

  @override
  State<HomeCore> createState() => _HomeCoreState();
}

class _HomeCoreState extends State<HomeCore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Puki Core"),
      ),
    );
  }
}
