import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:puki/src/ui/widgets/common.dart';
import 'package:wee_kit/loading.dart';

class AppbarMenus extends StatelessWidget {
  final PmChat data;
  const AppbarMenus({super.key, required this.data});

  Map<String, PopupMenuItem<String>> get menus {
    return {
      "GROUP_INFO": PopupMenuItem(
        value: "GROUP_INFO",
        child: Text("Group Info"),
      ),
      "CLEAR_CHAT": PopupMenuItem(
        value: "CLEAR_CHAT",
        enabled: data.messages.isNotEmpty,
        child: Text("Clear Chat"),
      ),
      "LEAVE_GROUP": PopupMenuItem(
        value: "LEAVE_GROUP",
        child: Text("Leave Group"),
      ),
      "DELETE_GROUP": PopupMenuItem(
        value: "DELETE_GROUP",
        child: Text("Delete Group"),
      ),
    };
  }

  List<PopupMenuItem<String>> menuItems() {
    if (data.room!.roomType == PmRoomType.private) {
      return [
        menus["CLEAR_CHAT"]!,
      ];
    }
    return [
      menus["CLEAR_CHAT"]!,
      if (data.room!.group!.createdBy != Puki.user.currentUser!.id) menus["LEAVE_GROUP"]!,
      if (data.room!.group!.createdBy == Puki.user.currentUser!.id) menus["DELETE_GROUP"]!,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) => menuItems(),
      onSelected: (value) {
        if (value == "CLEAR_CHAT") {
          return _clearChat(context);
        }
        if (value == "LEAVE_GROUP") {
          return _leaveGroup(context);
        }
        if (value == "DELETE_GROUP") {
          return _deleteGroup(context);
        }
      },
    );
  }

  void _deleteGroup(BuildContext context) {
    showAlertDialog(
      context,
      title: "Delete Group",
      onPositive: () async {
        Navigator.pop(context);

        try {
          WeeLoading.showOverlay(
            context,
            barrierColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            customChild: Center(child: CircularProgressIndicator()),
          );
          await Future.delayed(Duration(seconds: 1));
          await Controller.room.deleteGroup(data.room!);

          if (!context.mounted) return;

          Navigator.pop(context);
          Navigator.pop(context);
          showSnackBar(context, "Delete Group Success");
        } catch (e) {
          Navigator.pop(context);
          showSnackBar(context, e.toString(), seconds: 2);
        }
      },
    );
  }

  void _leaveGroup(BuildContext context) {
    showAlertDialog(
      context,
      title: "Leave Group",
      onPositive: () async {
        Navigator.pop(context);

        try {
          WeeLoading.showOverlay(
            context,
            barrierColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            customChild: Center(child: CircularProgressIndicator()),
          );

          await Controller.room.leaveGroup(data.room!);

          if (!context.mounted) return;

          Navigator.pop(context);
          Navigator.pop(context);
          showSnackBar(context, "Leave Group Success");
        } catch (e) {
          Navigator.pop(context);
          showSnackBar(context, e.toString(), seconds: 2);
        }
      },
    );
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
                await Controller.message.clearMessage(data.room!.id, List.from(data.messages));
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
