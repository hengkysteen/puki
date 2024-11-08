import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/pages/create_group_page.dart';
import 'package:puki_example/services/users.dart';

enum ContactPageAction { CHAT, GET_USER_ID }

class ContactPage extends StatelessWidget {
  final ContactPageAction action;

  const ContactPage({super.key, this.action = ContactPageAction.CHAT});

  Widget _item(BuildContext context, List<PmUser> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (c, i) {
        final contactUser = users[i];
        return ListTile(
          leading: CircleAvatar(),
          title: Text(contactUser.name),
          subtitle: Text(contactUser.email, overflow: TextOverflow.ellipsis),
          onTap: () {
            if (action == ContactPageAction.CHAT) {
              final target = PukiChatRoom(createRoom: PmCreatePrivateRoom(receiver: contactUser.id));

              print(target.createRoom);

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
            } else if (action == ContactPageAction.GET_USER_ID) {
              Navigator.pop(context, contactUser);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: Text("Contact")),
      body: Column(
        children: [
          Visibility(
            visible: action == ContactPageAction.CHAT,
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.group)),
              title: Text("New Group"),
              subtitle: Text("Create new group"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateGroupPage()));
              },
            ),
          ),
          // Visibility(
          //   visible: action == ContactPageAction.CHAT,
          //   child: ListTile(
          //     leading: CircleAvatar(child: Icon(Icons.group)),
          //     title: Text("New Group 2"),
          //     subtitle: Text("Create group"),
          //     onTap: () async {
          //       List<FcUser> user = await Fckit.firestore.user.getUsers();

          //       final page = ChatRoomPage(
          //         messageInputTypes: MyFckitCustomInput.register,
          //         createRoom: CreateGroupRoom(
          //           logo: "",
          //           createdBy: Fckit.user.currentUser!.id,
          //           name: "Pukimak",
          //           members: user.map((e) => e.id).toList(),
          //         ),
          //       );
          //       if (!context.mounted) return;
          //       WeeNavigate.to(context, page, replace: true);
          //     },
          //   ),
          // ),
          Expanded(
            child: FutureBuilder(
              future: Puki.firestore.user.getAllUsers(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center();
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                List<PmUser> users = snapshot.data!;

                users.removeWhere((e) => e.id == Users.currentUser!['id']);
                return _item(context, users);
              }),
            ),
          ),
        ],
      ),
    );
  }
}
