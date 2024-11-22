import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/pages/create_group.dart';
import 'package:puki_example/puki_modules/inputs/inputs.dart';
import 'package:puki_example/services/user.dart';
import 'package:puki_example/widgets/image_cache.dart';

enum ContactAction { CHAT, GET_USER_ID }

class Contact extends StatelessWidget {
  final ContactAction action;
  const Contact({super.key, this.action = ContactAction.CHAT});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: Text("Contact")),
      body: FutureBuilder(
        future: Puki.firestore.user.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData) return SizedBox();

          List<PmUser> users = snapshot.data!;

          users.removeWhere((e) => e.id == UserControl().user!.id);

          if (users.isEmpty) return Center(child: Text("No Contact"));

          return ListView.builder(
            itemCount: users.length + 1, // add 1 for widget
            itemBuilder: (c, i) {
              if (i == 0) {
                return Column(
                  children: [
                    Visibility(
                      visible: action == ContactAction.CHAT,
                      child: ListTile(
                        leading: CircleAvatar(child: Icon(Icons.group)),
                        title: Text("New Group"),
                        subtitle: Text("Create new group"),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CreateGroupPage()));
                        },
                      ),
                    ),
                    Visibility(
                      visible: action == ContactAction.CHAT,
                      child: ListTile(
                        leading: CircleAvatar(child: Icon(Icons.group)),
                        title: Text("Fairy Tail"),
                        subtitle: Text("Group members is all users"),
                        onTap: () async {
                          final page = PukiChatRoom(
                            createRoom: PmCreateGroupRoom(
                              logo: "https://i.ibb.co.com/RCy7Kjs/fairy-tail.png",
                              createdBy: UserControl().user!.id,
                              name: "Fairy Tail",
                              members: users.map((e) => e.id).toList(),
                            ),
                          );
                          if (!context.mounted) return;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
                        },
                      ),
                    ),
                  ],
                );
              }

              final contactUser = users[i - 1]; // remove 1 added widget before
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: contactUser.avatar.isEmpty ? null : ImageCached.networkProvider(contactUser.avatar),
                  child: contactUser.avatar.isEmpty ? Text(contactUser.firstName[0].toUpperCase()) : null,
                ),
                title: Text(contactUser.name),
                subtitle: Text(contactUser.email, overflow: TextOverflow.ellipsis),
                onTap: () {
                  if (action == ContactAction.CHAT) {
                    final target = PukiChatRoom(
                      registerInputs: PukiModule.inputs,
                      createRoom: PmCreatePrivateRoom(receiver: contactUser.id),
                    );
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
                  } else if (action == ContactAction.GET_USER_ID) {
                    Navigator.pop(context, contactUser);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
