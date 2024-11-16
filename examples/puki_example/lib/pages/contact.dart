import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/puki_ui.dart';
import 'package:puki_example/puki_modules/inputs/inputs.dart';
import 'package:puki_example/services/user.dart';

import '../widgets/image_cache.dart';

enum ContactAction { CHAT, GET_USER_ID }

class Contact extends StatefulWidget {
  final ContactAction action;
  const Contact({super.key, this.action = ContactAction.CHAT});
  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
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
            itemCount: users.length,
            itemBuilder: (c, i) {
              final contactUser = users[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: ImageCached.networkProvider(contactUser.avatar),
                ),
                title: Text(contactUser.name),
                subtitle: Text(contactUser.email, overflow: TextOverflow.ellipsis),
                onTap: () {
                  if (widget.action == ContactAction.CHAT) {
                    final target = PukiChatRoom(
                      registerInputs: PukiModule.inputs,
                      createRoom: PmCreatePrivateRoom(receiver: contactUser.id),
                    );
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
                  } else if (widget.action == ContactAction.GET_USER_ID) {
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
