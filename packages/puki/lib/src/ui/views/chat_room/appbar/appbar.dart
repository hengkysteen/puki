import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/components/component.dart';
import 'package:puki/src/ui/views/chat_room/appbar/appbar_menus.dart';
import 'package:puki/src/ui/views/chat_room/appbar/titles/group.dart';
import 'package:puki/src/ui/views/chat_room/appbar/titles/private.dart';

class ChatRoomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final PmChat data;
  const ChatRoomAppbar({super.key, required this.data});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget getTitle() {
    if (data.room!.roomType == PmRoomType.private) {
      return PrivateTitle(chatData: data);
    }
    return GroupTitle(chatData: data);
  }

  Widget leading() {
    if (data.room!.roomType == PmRoomType.private) {
      return Pc.user.getAvatar(data.members.firstWhere((e) => e.id != PukiCore.user.currentUser!.id));
    }
    return Pc.room.groupAvatar(data.room!.group!, showShadow: false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      notificationPredicate: (notification) => false,
      elevation: 1,
      leadingWidth: 46,
      centerTitle: false,
      titleSpacing: 5,
      title: data.members.isEmpty
          ? SizedBox()
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                leading(),
                getTitle(),
              ],
            ),
      actions: [
        AppbarMenus(data: data),
        SizedBox(width: 5),
      ],
    );
  }
}
