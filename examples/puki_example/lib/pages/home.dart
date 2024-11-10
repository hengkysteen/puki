import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/pages/chat.dart';
import 'package:puki_example/pages/messages.dart';
import 'package:puki_example/pages/splash.dart';
import 'package:puki_example/services/storage.dart';
import 'package:puki_example/services/users.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomePage({super.key, required this.user});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PmUser currentuser;

  @override
  void initState() {
    setState(() {
      currentuser = PmUser(id: widget.user['id'], name: widget.user['name']);
    });
    super.initState();
  }

  Future<void> _logout(BuildContext context) async {
    await Storage.clearUser();
    await Puki.user.logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Splash()));
  }

  Future<void> startRoom(BuildContext context) async {
    List<PmUser> users = await Puki.firestore.user.getAllUsers();
    users.removeWhere((e) => e.id == currentuser.id);
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Visibility(
              visible: users.isNotEmpty,
              child: ListTile(
                title: Text("Create Group"),
                subtitle: Text("Members = all users"),
                onTap: () async {
                  Navigator.pop(context);
                  final room = await Puki.firestore.room.createGroupRoom(
                    user: currentuser,
                    name: "Fairy Tail",
                    memberIds: Users.dummy.map((e) => e['id'] as String).toList(),
                  );
                  if (!context.mounted) return;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(user: widget.user, room: room)));
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.name),
                    onTap: () async {
                      Navigator.pop(context);
                      final room = await Puki.firestore.room.createPrivateRoom(currentuser.id, user.id);
                      if (!context.mounted) return;
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(user: widget.user, room: room)));
                    },
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(onPressed: () async => await _logout(context), icon: Icon(Icons.logout)),
        title: Text("Hi, ${widget.user['name']}"),
        actions: [
          PukiUnreadBadge(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MessagesPage()));
            },
          ),
          SizedBox(width: 8)
        ],
      ),
    );
  }
}
