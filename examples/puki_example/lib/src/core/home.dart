import 'package:flutter/material.dart';
import 'package:puki/puki.dart';

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
      body: ListView(
        children: [
          ListTile(
            title: Text("Puki Firestore instance"),
            onTap: () {
              print(Puki.firestore.instance);
            },
          ),
          ListTile(
            title: Text("Get Message"),
            onTap: () async {
              final message = await Puki.firestore.message.getSingleMessage("1");
              print(message);
            },
          ),
          ListTile(
            title: Text("Get All Messages"),
            onTap: () async {
              final message = await Puki.firestore.message.getAllMessages();
              print(message);
            },
          ),
          ListTile(
            title: Text("Create Messages"),
            onTap: () async {
              final message = await Puki.firestore.message.createMessage(
                senderId: 'A',
                room: PmRoom(
                  id: "1",
                  type: "private",
                  users: ["1", "2"],
                ),
                messageContent: PmContent(type: "text", message: "Hallo"),
              );
              print(message);
            },
          ),
        ],
      ),
    );
  }
}
