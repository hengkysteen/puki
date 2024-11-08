import 'package:flutter/material.dart';
import 'package:puki/puki.dart';

class ChatPage extends StatefulWidget {
  final Map user;
  final PmRoom room;
  const ChatPage({super.key, required this.user, required this.room});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late PmUser currentUser;
  @override
  void initState() {
    setState(() {
      currentUser = PmUser(id: widget.user['id'], name: widget.user['name']);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chat"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
          onPressed: () {
            Puki.firestore.message.sendMessage(
              user: currentUser,
              room: widget.room,
              content: PmContent(type: "text", message: "HI"),
            );
          },
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: StreamBuilder(
            stream: Puki.firestore.message.streamMyMessages(userId: widget.user['id'], roomId: widget.room.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              final data = snapshot.data;
              Puki.firestore.message.readMessages(userId: widget.user['id'], room: widget.room, messages: data!);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: data
                    .map((e) => Container(
                          margin: EdgeInsets.all(20),
                          color: Colors.grey[200],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ID = ${e.id}"),
                              Text("Message = ${e.content.message}"),
                              Text("Message sender = ${e.sender}"),
                              Text("Message users = ${e.users}"),
                              Text("Message Status = ${e.status.toString()}"),
                              Text("Visible = ${e.visibleTo}"),
                              Text("Read By = ${e.readBy.map((e) => e!.user).toList()}"),
                            ],
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ));
  }
}
