import 'dart:async';
import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'chat_list_item.dart';

class PukiChatList extends StatelessWidget {
  final Widget? onEmpty;
  final void Function(PmRoom room)? onTap;
  final void Function(PmRoom room)? overrideLongPress;

  const PukiChatList({super.key, this.onTap, this.overrideLongPress, this.onEmpty});

  Widget onEmptyList() {
    if (onEmpty != null) return onEmpty!;
    return Center(child: Text('No message yet', style: TextStyle(color: Colors.grey)));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Puki.user.currentUser == null ? Stream.empty() : Puki.firestore.room.streamAllUserRooms(Puki.user.currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw snapshot.error!;
        }

        if (!snapshot.hasData) return const SizedBox();

        final rooms = snapshot.data!;

        if (rooms.isEmpty) return onEmptyList();

        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: ((context, index) {
            return PukiChatListItem(
              room: rooms[index],
              onTap: onTap,
              overrideLongPress: overrideLongPress,
            );
          }),
        );
      },
    );
  }
}
