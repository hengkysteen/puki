import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/pages/contact.dart';
import 'package:puki_example/puki_modules/inputs/camera/photo/photo.dart';
import 'package:puki_example/puki_modules/inputs/document/document.dart';
import 'package:puki_example/puki_modules/inputs/stickers/stikers.dart';
import 'package:puki_example/services/users.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});
  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  List<PmUser> users = [];
  final currentUser = Puki.user.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Group")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 120, child: Text("Group Name")),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(filled: true, border: InputBorder.none),
                        controller: _nameCtrl,
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Group Members"),
                      IconButton(
                        onPressed: _onTap,
                        icon: Icon(Icons.person_add, color: Theme.of(context).primaryColor),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  trailing: IconButton(icon: Icon(Icons.remove), onPressed: () => setState(() => users.removeAt(index))),
                  title: Text(users[index].name),
                  subtitle: Text(users[index].email),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(20),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(15),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[200],
                disabledForegroundColor: Colors.grey,
              ),
              onPressed: users.isEmpty || _nameCtrl.text.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);

                      final page = PukiChatRoom(
                        registerInputs: [PukiInputStickers.type, DokumenInput.type, InputCameraPhoto.type],
                        createRoom: PmCreateGroupRoom(
                          name: _nameCtrl.text,
                          createdBy: Users.currentUser!['id'],
                          members: users.map((e) => e.id).toList(),
                        ),
                      );

                      Navigator.pop(context);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
                    },
              child: Text("Create"),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _onTap() async {
    final user = await Navigator.push(context, MaterialPageRoute(builder: (_) => ContactPage(action: ContactPageAction.GET_USER_ID)));

    if (user != null) {
      setState(() {
        users.removeWhere((e) => e.id.contains(user.id));
        users.add(user);
      });
    }
  }
}
