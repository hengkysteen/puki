import 'dart:async';

import 'package:get/get.dart';
import 'package:puki/puki.dart';

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
}
