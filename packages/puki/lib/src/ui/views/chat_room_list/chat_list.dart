import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'chat_list_item.dart';

class PukiChatList extends StatefulWidget {
  final Widget? onEmpty;
  final void Function(PmRoom room)? onTap;
  final void Function(PmRoom room)? overrideLongPress;

  const PukiChatList({super.key, this.onTap, this.overrideLongPress, this.onEmpty});

  @override
  State<PukiChatList> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<PukiChatList> {
  @override
  void initState() {
    super.initState();
  }

  Widget onEmptyList() {
    if (widget.onEmpty != null) return widget.onEmpty!;
    return Center(child: Text('No message yet', style: TextStyle(color: Colors.grey)));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Puki.firestore.room.streamAllUserRooms(Puki.user.currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) throw snapshot.error!;

        if (!snapshot.hasData) return const SizedBox();

        final rooms = snapshot.data!;

        if (rooms.isEmpty) return onEmptyList();

        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: ((context, index) {
            return PukiChatListItem(
              room: rooms[index],
              onTap: widget.onTap,
              overrideLongPress: widget.overrideLongPress,
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
