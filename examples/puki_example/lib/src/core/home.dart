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
                senderId: '1',
                room: PmRoom(
                  id: "1",
                  type: "private",
                  users: ["1", "2"],
                ),
                messageContent: PmContent(type: "text", message: "Hallo"),
              );
              print(message.toJson());
            },
          ),
          ListTile(
            title: Text("Delete All Messages"),
            onTap: () async {
              await Puki.firestore.message.deleteMessages();
            },
          ),
          StreamBuilder(
            stream: Puki.firestore.message.streamMyMessages(userId: "1", roomId: "1"),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              final data = snapshot.data;
              return Column(
                children: data!
                    .map((e) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("ID = ${e.id}"),
                            Text("Message = ${e.content.message}"),
                            Text("Visible = ${e.visibleTo}"),
                          ],
                        ))
                    .toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
