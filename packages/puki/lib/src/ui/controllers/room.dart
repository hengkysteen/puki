import 'dart:async';

import 'package:get/get.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/ui/controllers/controller.dart';

class RoomController extends GetxController {
  Future<PmRoom> createRoom({required PmUser user, required PmCreateRoom createRoom}) async {
    late PmRoom room;
    // CreateRoom is Private
    if (createRoom is PmCreatePrivateRoom) {
      final response = await Puki.firestore.room.createPrivateRoom(user.id, createRoom.receiver);
      room = response;
    }
    // CreateRoom is Group
    if (createRoom is PmCreateGroupRoom) {
      if (createRoom.members.isEmpty) throw Exception("Members can't be empty");
      final response = await Puki.firestore.room.createGroupRoom(
        user: user,
        name: createRoom.name,
        logo: createRoom.logo,
        memberIds: createRoom.members,
      );
      room = response;
    }
    return room;
  }

  Future<void> leaveGroup(PmRoom room) async {
    if (room.roomType == PmRoomType.private) throw Exception("Only for Group Room");
    await Puki.firestore.room.removeMembers(room, [Puki.user.currentUser!.id]);
    Puki.firestore.message.sendMessage(
      user: Puki.user.currentUser!,
      room: room,
      content: PmContent(type: "text", message: "${Puki.user.currentUser!.firstName} leave group"),
      isSystem: true,
    );
  }

  Future<void> deleteGroup(PmRoom room) async {
    if (room.roomType == PmRoomType.private) throw Exception("Only for Group Room");
    await Puki.firestore.room.deleteRoom(room.id, Puki.user.currentUser!.id);
    Controller.chatRoom.reset();
  }
}
