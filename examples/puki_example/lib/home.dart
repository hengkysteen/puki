import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/app.dart';
import 'package:puki_example/dummy_users.dart';
import 'package:puki_example/storage.dart';

class HomePage extends StatefulWidget {
  final Map user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text(widget.user['name']),
        title: Text("Puki Core"),
        actions: [
          IconButton(
              onPressed: () async {
                await Storage.clearUser();
                if (!context.mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Splash()));
              },
              icon: Icon(Icons.logout))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.create),
          onPressed: () {
            final users = Dummy.users.where((e) => e['id'] != widget.user['id']).toList();
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(users[index]['name']),
                      onTap: () async {
                        Navigator.pop(context);
                        await Puki.firestore.room.createPrivateRoom(widget.user['id'], users[index]['id']);
                      },
                    );
                  },
                );
              },
            );
          }),
      body: StreamBuilder(
        stream: Puki.firestore.room.streamAllUserRooms(widget.user['id'], showUnusedRoom: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();
          final rooms = snapshot.data;
          return Column(
            children: List.generate(rooms!.length, (i) {
              final room = rooms[i];
              return ListTile(
                title: Text("Room ${room.id}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Members = ${room.users.map((e) => e).toList()}"),
                    Text("Last Message = ${room.lastMessage?.by}"),
                  ],
                ),
                trailing: Text("Unread counter = ${room.private?.unread}  "),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(user: widget.user, room: room),
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }
}

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
              content: PmContent(type: "text", message: "HAlo"),
            );
          },
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: Puki.firestore.message.streamMyMessages(userId: widget.user['id'], roomId: widget.room.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              final data = snapshot.data;
              print(data!.length);

              Puki.firestore.message.readMessages(userId: widget.user['id'], room: widget.room, messages: data);

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
