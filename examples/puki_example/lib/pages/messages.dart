import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/pages/contact.dart';
import 'package:puki_example/puki_modules/inputs/stickers/stikers.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messages"), centerTitle: false),
      body: PukiChatList(
        onTap: (room) {
          final chatPage = PukiChatRoom(
            registerInputs: [PukiInputStickers.type],
            roomId: room.id,
            onMessageSended: (message) {
              print("RESULT = ${message.toJson()}");
            },
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => chatPage));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.people),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ContactPage()));
        },
      ),
    );
  }
}
