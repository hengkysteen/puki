import 'dart:async';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/controllers/controller.dart';

class RoomController {

  
  Future<PmRoom> createRoom({required PmUser user, required PmCreateRoom createRoom}) async {
    late PmRoom room;
    // CreateRoom is Private
    if (createRoom is PmCreatePrivateRoom) {
      final response = await PukiCore.firestore.room.createPrivateRoom(user.id, createRoom.receiver);
      room = response;
    }
    // CreateRoom is Group
    if (createRoom is PmCreateGroupRoom) {
      if (createRoom.members.isEmpty) throw Exception("Members can't be empty");
      final response = await PukiCore.firestore.room.createGroupRoom(
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
    await PukiCore.firestore.room.removeMembers(room, [PukiCore.user.currentUser!.id]);
    PukiCore.firestore.message.sendMessage(
      user: PukiCore.user.currentUser!,
      room: room,
      content: PmContent(type: "text", message: "${PukiCore.user.currentUser!.firstName} leave group"),
      isSystem: true,
    );
  }

  Future<void> deleteGroup(PmRoom room) async {
    if (room.roomType == PmRoomType.private) throw Exception("Only for Group Room");
    await PukiCore.firestore.room.deleteRoom(room.id, PukiCore.user.currentUser!.id);
    Controller.chatRoom.reset();
  }
}
