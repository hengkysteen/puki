import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/ui/widgets/common.dart';

class AppbarMenus extends StatelessWidget {
  final PmChat data;
  const AppbarMenus({super.key, required this.data});

  Map<String, PopupMenuItem<int>> get menus => {
        "GROUP_INFO": PopupMenuItem(value: 0, child: Text("Group Info")),
        "LEAVE_GROUP": PopupMenuItem(value: 2, textStyle: TextStyle(color: Colors.red), child: Text("Leave Group")),
      };

  List<PopupMenuItem<int>> menuItems() {
    if (data.room!.roomType == PmRoomType.private) {
      return [menus["CLEAR_CHAT"]!];
    }
    return [menus["GROUP_INFO"]!, menus["LEAVE_GROUP"]!];
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (_) => menuItems(),
      onSelected: (v) => menuOnSelected(v, data.room!, Puki.user.currentUser!.id, context),
    );
  }

  Future<void> menuOnSelected(int value, PmRoom room, String userId, BuildContext context) async {
    if (value == 1) {
      _clearChat(context);
    }
  }

  void _clearChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Clear chat'),
          content: Text('Are you sure ?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Puki.firestore.message.hideMessages(
                  userId: Puki.user.currentUser!.id,
                  roomId: data.room!.id,
                  messages: data.messages,
                );
                if (!context.mounted) return;
                showSnackBar(context, "Chat cleared");
              },
              child: Text("Clear"),
            )
          ],
        );
      },
    );
  }
}
