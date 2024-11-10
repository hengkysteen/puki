import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/ui/components/component.dart';
import 'package:puki/src/ui/widgets/common.dart';

class PukiChatListItem extends StatelessWidget {
  final PmRoom room;
  final void Function(PmRoom room)? onTap;
  final void Function(PmRoom room)? overrideLongPress;

  const PukiChatListItem({super.key, required this.room, this.onTap, this.overrideLongPress});

  Widget _widgetLastMessage(List<PmUser?> users, PmRoom room) {
    String text = room.lastMessage?.message ?? '';

    String? typingStatus = PukiComp.user.memberTypingStatus(users, room.id);

    if (typingStatus != null) {
      return Text(typingStatus, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    return Text(text.trimLeft(), maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  Widget roomName(PmRoom room, List<PmUser> users) {
    if (room.type == "group") {
      return Text(room.group!.name);
    }
    final receiver = users.firstWhereOrNull((e) => e.id != Puki.user.currentUser!.id);
    return Text(receiver!.name);
  }

  Widget roomAvatar(PmRoom room, List<PmUser> users) {
    if (room.type == "group") {
      return PukiComp.room.groupAvatar(room.group!);
    }

    final receiver = users.firstWhereOrNull((e) => e.id != Puki.user.currentUser!.id);
    return PukiComp.user.getAvatar(receiver);
  }

  @override
  Widget build(BuildContext context) {
    // COPY USERS FROM ROOM
    final List<String> members = List.from(room.users);
    // REMOVE CURRENT USER FROM MEMBERS
    members.removeWhere((userId) => userId == Puki.user.currentUser!.id);

    return StreamBuilder(
      stream: Puki.firestore.user.streamAllUsers(userIds: members),
      builder: (context, snapshot) {
        if (snapshot.hasError) throw Exception(snapshot.error.toString());
        if (!snapshot.hasData) return const Center();
        final users = snapshot.data;

        return ListTile(
          leading: roomAvatar(room, users!),
          title: roomName(room, users),
          subtitle: _widgetLastMessage(users, room),
          trailing: PukiComp.room.unreadXlastMessageTime(room),
          onTap: onTap == null ? null : () => onTap!(room),
          onLongPress: overrideLongPress == null ? () async => await deleteRoom(context, room) : () => overrideLongPress!(room),
        );
      },
    );
  }

  Future<void> deleteRoom(BuildContext context, PmRoom room) async {
    final nav = Navigator.of(context);
    return showAlertDialog(
      context,
      title: 'Delete this room ?',
      content: 'Messages will be removed\nfrom this account.',
      positiveText: 'Delete',
      onPositive: () async {
        nav.pop();
        await Puki.firestore.room.hideRoom(room, Puki.user.currentUser!.id);
        if (!nav.mounted) return;
        showSnackBar(nav.context, "Room deleted.");
      },
    );
  }
}
