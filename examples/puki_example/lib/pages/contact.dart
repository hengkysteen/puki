import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/pages/create_group_page.dart';
import 'package:puki_example/services/users.dart';

enum ContactPageAction { CHAT, GET_USER_ID }

class ContactPage extends StatefulWidget {
  final ContactPageAction action;
  const ContactPage({super.key, this.action = ContactPageAction.CHAT});
  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<PmUser> contactUsers = [];
  bool _isloading = false;
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
            if (widget.action == ContactPageAction.CHAT) {
              final target = PukiChatRoom(createRoom: PmCreatePrivateRoom(receiver: contactUser.id));
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
            } else if (widget.action == ContactPageAction.GET_USER_ID) {
              Navigator.pop(context, contactUser);
            }
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    setState(() {
      _isloading = true;
    });
    final data = await Puki.firestore.user.getAllUsers();
    if (data.isNotEmpty) {
      data.removeWhere((e) => e.id == Users.currentUser!['id']);
      setState(() {
        contactUsers = data;
      });
    }
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: Text("Contact")),
      body: Builder(
        builder: (context) {
          if (_isloading) {
            return Center();
          }
          return Column(
            children: [
              Visibility(
                visible: widget.action == ContactPageAction.CHAT,
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.group)),
                  title: Text("New Group"),
                  subtitle: Text("Create new group"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateGroupPage()));
                  },
                ),
              ),
              Expanded(child: _item(context, contactUsers)),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    contactUsers.clear();
    super.dispose();
  }
}
