import 'dart:convert';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: Splash());
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isLoading = false;
  @override
  void initState() {
    setup();
    super.initState();
  }

  setup() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    final user = await Storage.getUser();
    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    } else {
      await Puki.user.setup(id: user['id']);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(user: user)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Center(child: CircularProgressIndicator()) : Center(),
    );
  }
}

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
                    name: Faker().animal.name(),
                    memberIds: Dummy.users.map((e) => e['id'] as String).toList(),
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
        title: Text("Hi, ${widget.user['name']}"),
        actions: [IconButton(onPressed: () async => await _logout(context), icon: Icon(Icons.logout))],
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.create), onPressed: () async => await startRoom(context)),
      body: StreamBuilder(
        stream: Puki.firestore.room.streamAllUserRooms(widget.user['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();
          final rooms = snapshot.data;
          return Column(
            children: List.generate(rooms!.length, (i) {
              final room = rooms[i];
              final unreadMessage = Puki.firestore.room.getUnreadData(room);
              return ListTile(
                leading: Text(room.type.toUpperCase()),
                title: Text("Room ${room.id}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Members = ${room.users.map((e) => e).toList()}"),
                    Text("Last Message = ${room.lastMessage?.by}"),
                  ],
                ),
                trailing: Text(
                  "Unread = ${unreadMessage![currentuser.id]}",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(user: widget.user, room: room),
                    ),
                  );
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Actions"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Puki.firestore.room.hideRoom(room, widget.user['id']);
                            },
                            child: Text("Hide Room"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Puki.firestore.room.deleteRoom(room.id, widget.user['id']);
                            },
                            child: Text("Delete Room"),
                          ),
                        ],
                      );
                    },
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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    Dummy.users.sort((a, b) => a['name'].compareTo(b['name']));
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: ListView(
        children: [
          // TextButton(
          //   onPressed: () {
          //     final user = PmUser(id: "user1", name: "Bokero Keopi", userData: {'role': 'admin'});

          //     Puki.firestore.user.createUser(user);
          //   },
          //   child: Text("SET USER"),
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: Dummy.users.map((e) {
              return ListTile(
                title: Text(e['name']),
                subtitle: Text(e['email']),
                trailing: TextButton(
                  onPressed: () async => await setUser(context, e, isLogin: true),
                  child: Text("Login"),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> setUser(BuildContext context, Map<String, dynamic> user, {bool isLogin = true}) async {
    await Storage.saveUser(user);
    await Puki.user.setup(
      id: user['id'],
      name: user['name'],
      email: user['email'],
      avatar: user['avatar'],
    );
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(user: user)));
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
            final message = Faker().lorem.sentence();
            Puki.firestore.message.sendMessage(
              user: currentUser,
              room: widget.room,
              content: PmContent(type: "text", message: message),
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

class Dummy {
  static List<Map<String, dynamic>> users = [
    {
      "id": "1",
      "name": "Gildarts Clivex",
      "email": "gildartsclive@puki.com",
      "avatar": 'https://i.ibb.co.com/0hLhs05/gildart.jpg',
      "password": "123123",
    },
    {
      "id": '2',
      "name": "Juvia Lockser",
      "email": "juvialockser@puki.com",
      "avatar": 'https://drive.google.com/uc?export=download&id=1PKAsORqs9e3gbKOtmYTJgFPFyAY3yHjN',
      "password": "123123",
    },
    {
      "id": '3',
      "name": "Erza Scarlet",
      "email": "erzascarlet@puki.com",
      "avatar": 'https://i.ibb.co.com/M953zff/erza.jpg',
      "password": "123123",
    },
    {
      "id": '4',
      "name": "Makarov Dreyar",
      "email": "makarovdreyar@puki.com",
      "avatar": 'https://i.ibb.co.com/BKw3ZYw/makarov.jpg',
      "password": "123123",
    },
    {
      "id": "5",
      "name": "Natsu Dragneel",
      "email": "natsudragneel@puki.com",
      "avatar": '',
      "password": "123123",
    },
    {
      "id": "6",
      "name": "Gray Fullbuster",
      "email": "grayfullbuster@puki.com",
      "avatar": 'https://i.ibb.co.com/L9yFjVC/gray.jpg',
      "password": "123123",
    },
    {
      "id": "7",
      "name": "Happy",
      "email": "happy@puki.com",
      "avatar": "",
      "password": "123123",
    }
  ];
}

class Storage {
  static const String _userKey = 'user';
  // Fungsi untuk menyimpan data pengguna ke SharedPreferences
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(userData);
    await prefs.setString(_userKey, userJson);
  }

  // Fungsi untuk mengambil data pengguna dari SharedPreferences
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // Fungsi untuk menghapus data pengguna dari SharedPreferences
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
