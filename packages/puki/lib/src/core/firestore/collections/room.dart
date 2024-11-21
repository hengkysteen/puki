import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/firestore/collections/message.dart';
import 'package:puki/src/core/helper/log.dart';
import '../../helper/fields.dart';
import 'base.dart';

/// Puki Firesotre Rooms Collection
class RoomsCollection extends BaseCollection {
  final FirebaseFirestore _firestore;
  RoomsCollection(this._firestore) : super();

  MessagesCollection get _messagesCollection => Puki.firestore.message;

  /// Room Collections Reference
  CollectionReference<Map<String, dynamic>> get collection => _firestore.collection(settings.getCollectionPath("rooms"));

  Query<Map<String, dynamic>> _queryRooms(String userId, {bool showUnusedRoom = false}) {
    Query<Map<String, dynamic>> query = collection.where(F.USERS, arrayContains: userId);
    if (!showUnusedRoom) {
      query = query.where(F.LAST_MESSAGE, isNotEqualTo: null).orderBy("${F.LAST_MESSAGE}.${F.TIME}", descending: true);
    }
    return query;
  }

  List<PmRoom> _parseRooms(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {required String userId, bool showInvisibleRoom = false}) {
    List<PmRoom> rooms = docs.map((e) => PmRoom.fromJson(e.data())).toList();
    if (!showInvisibleRoom) {
      return rooms.where((room) => room.usersInfo.any((user) => user.id == userId && user.isVisible)).toList();
    }
    return rooms;
  }

  Future<List<PmRoom>> getAllUserRooms(String userId, {bool showUnusedRoom = false, bool showInvisibleRoom = false}) async {
    final query = await _queryRooms(userId, showUnusedRoom: showUnusedRoom).get();
    return _parseRooms(query.docs, userId: userId, showInvisibleRoom: showInvisibleRoom);
  }

  Stream<List<PmRoom>> streamAllUserRooms(String userId, {bool showUnusedRoom = false, bool showInvisibleRoom = false}) {
    devLog("RoomCollection > streamAllUserRooms | userId = $userId");
    final query = _queryRooms(userId, showUnusedRoom: showUnusedRoom).snapshots();
    return query.map((e) => _parseRooms(e.docs, userId: userId, showInvisibleRoom: showInvisibleRoom));
  }

  Stream<PmRoom> streamSingleRoom(String roomId) {
    final doc = collection.doc(roomId).snapshots();
    return doc.map((e) => PmRoom.fromJson(e.data()!));
  }

  Future<List<PmRoom>> _isPrivateRoomExist(String sender, String receiver) async {
    final rooms = await getAllUserRooms(receiver, showUnusedRoom: true, showInvisibleRoom: true);
    return rooms.where((e) => e.users.contains(sender) && e.type == F.PRIVATE).toList();
  }

  Future<PmRoom> createPrivateRoom(String sender, String receiver) async {
    late PmRoom room;
    final existingRoom = await _isPrivateRoomExist(sender, receiver);
    if (existingRoom.isEmpty) {
      // Create new room
      final document = collection.doc();
      final dataPrivateRoom = PmPrivate(receiver: receiver, sender: sender, unread: {sender: 0, receiver: 0});
      final data = PmRoom(type: F.PRIVATE, private: dataPrivateRoom, id: document.id, users: [sender, receiver]);
      await document.set(data.toJson());
      final snapshot = await document.get();
      room = PmRoom.fromJson(snapshot.data() as Map<String, dynamic>);
    } else {
      // Return the existing room
      room = PmRoom.fromJson(existingRoom.first.toJson());
    }
    return room;
  }

  Future<PmRoom> createGroupRoom({required PmUser user, required String name, required List<String> memberIds, String? logo}) async {
    late PmRoom room;

    memberIds
      ..remove(user.id)
      ..add(user.id);

    final document = collection.doc();

    final groupData = PmGroup(name: name, createdBy: user.id, unread: {for (var member in memberIds) member: 0}, logo: logo ?? "");

    final lastMessageData = PmLastMessage(name: "system", by: user.id, time: Timestamp.now(), message: "${user.firstName} started a group");

    final body = PmRoom(type: F.GROUP, group: groupData, lastMessage: lastMessageData, id: document.id, users: memberIds);

    await document.set(body.toJson());

    final response = await document.get();

    room = PmRoom.fromJson(response.data() as Map<String, dynamic>);

    return room;
  }

  Future<void> deleteRoom(String roomId, String userId) async {
    final batch = _firestore.batch();
    final messages = await _messagesCollection.getMyMessages(userId: userId, roomId: roomId);

    if (messages.isNotEmpty) {
      for (var message in messages) {
        batch.delete(_messagesCollection.collection.doc(message.id));
      }
    }
    batch.delete(collection.doc(roomId));
    batch.commit();
  }

  Future<void> hideRoom(PmRoom room, String userId) async {
    final info = PmUserInfo(id: userId, isVisible: false, isRoomMember: true, isAccountDeleted: false);

    await updateUserInfo(userInfo: [info], room: room);

    // If the user hides the room and there are unread messages, the unread count will be reset to 0,
    if (room.lastMessage!.by != userId) {
      await updateUnreadCount(room: room, userId: userId, operation: "reset");
    }

    final messages = await _messagesCollection.getMyMessages(userId: userId, roomId: room.id);

    await _messagesCollection.hideMessages(userId: userId, roomId: room.id, messages: messages);
  }

  Future<void> updateUserInfo({required List<PmUserInfo> userInfo, required PmRoom room, WriteBatch? writeBatch}) async {
    List<PmUserInfo> updatedUsersInfo = List.from(room.usersInfo);

    for (var newInfo in userInfo) {
      int index = updatedUsersInfo.indexWhere((info) => info.id == newInfo.id);

      if (index != -1) {
        updatedUsersInfo[index] = newInfo;
      }
    }

    final updateData = {
      F.USERS_INFO: updatedUsersInfo.map((info) => info.toJson()).toList(),
    };

    if (writeBatch != null) {
      writeBatch.update(collection.doc(room.id), updateData);
    } else {
      await collection.doc(room.id).update(updateData);
    }
  }

  /// Updates the unread message count for a specific user in a chat room.
  ///
  /// [operation] usage = 'add' or 'reset'.
  Future<void> updateUnreadCount({required PmRoom room, required String userId, required String operation, WriteBatch? writeBatch}) async {
    // Check if the user is a member of the room
    if (!room.users.contains(userId)) throw Exception('User $userId is not a member of room ${room.id}.');

    final unreadField = room.unreadField;

    Map<String, dynamic> updateData;

    switch (operation) {
      case 'add':
        if (room.type == 'private') {
          // Add unread count for the other user in a private chat
          final otherUserId = room.users.firstWhere((user) => user != userId);
          updateData = {
            '$unreadField.$otherUserId': FieldValue.increment(1),
          };
        } else {
          // Add unread count for all users except the sender in a group chat
          updateData = {
            for (var user in room.users.where((user) => user != userId)) '$unreadField.$user': FieldValue.increment(1),
          };
        }
        break;
      case 'reset':
        updateData = {
          '$unreadField.$userId': 0,
        };
        break;
      default:
        throw Exception('Invalid operation: $operation. Use "add" or "reset".');
    }
    if (writeBatch == null) {
      await collection.doc(room.id).update(updateData);
    } else {
      writeBatch.update(collection.doc(room.id), updateData);
    }
  }

  void updateLastMessage(PmRoom room, PmUser sender, PmContent content, {WriteBatch? writeBatch}) async {
    late String textMessage;
    if (room.roomType == PmRoomType.private) {
      textMessage = content.type == 'text' ? content.message : 'share ${content.type}';
    } else {
      textMessage = content.type == 'text' ? '${sender.firstName} : ${content.message}' : '${sender.firstName} share ${content.type}';
    }
    final data = {
      F.LAST_MESSAGE: PmLastMessage(name: sender.firstName, by: sender.id, time: Timestamp.now(), message: textMessage).toJson(),
    };
    if (writeBatch == null) {
      await collection.doc(room.id).update(data);
    } else {
      writeBatch.update(collection.doc(room.id), data);
    }
  }

  Stream<int> streamTotalUnread(String userId) {
    final data = streamAllUserRooms(userId);
    return data.map((room) => getTotalUnread(room, userId));
  }

  int getTotalUnread(List<PmRoom> rooms, String userId) {
    int total = 0;
    for (var d in rooms) {
      if (d.roomType == PmRoomType.group) {
        total = total += d.group!.unread![userId] as int;
      } else {
        total = total += d.private!.unread![userId] as int;
      }
    }
    return total;
  }

  Future<void> removeMembers(PmRoom room, List<String> users) async {
    if (users.contains(room.group!.createdBy)) throw Exception("Group owner can't be removed");

    await updateUserInfo(userInfo: users.map((user) => PmUserInfo(id: user, isRoomMember: false)).toList(), room: room);

    final unreadData = Map.from(room.group!.unread!)..removeWhere((key, _) => users.contains(key));

    await collection.doc(room.id).update(
      {
        F.FORMER_USERS: FieldValue.arrayUnion(users),
        F.USERS: FieldValue.arrayRemove(users),
        F.GROUP_UNREAD: unreadData,
      },
    );
  }
}
