import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:puki/puki.dart';

class PukiChatRoom extends StatefulWidget {
  final PmRoom? room;
  final PmCreateRoom? createRoom;
  const PukiChatRoom({super.key, this.room, this.createRoom});

  @override
  State<PukiChatRoom> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<PukiChatRoom> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatRoom"),
      ),
      body: Column(
        children: [
          Text("room = ${widget.room?.id}"),
          Text("create room = ${widget.createRoom.runtimeType}"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () async => await sendMessage(),
      ),
    );
  }

  Future<void> sendMessage() async {
    final message = Faker().lorem.sentence();

    await Puki.firestore.message.sendMessage(
      user: Puki.user.currentUser!,
      room: widget.room!,
      content: PmContent(type: "text", message: message),
    );
  }

  @override
  void dispose() async {
    super.dispose();
  }
}
