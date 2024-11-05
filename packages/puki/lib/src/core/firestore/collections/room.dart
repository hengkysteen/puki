import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/puki.dart';
import '../../helper/fields.dart';
import 'base.dart';

/// Puki Firesotre Rooms Collection
class RoomsCollection extends BaseCollection {
  final FirebaseFirestore _firestore;
  RoomsCollection(this._firestore) : super();

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

  String getUnreadField(PmRoom room) {
    if (room.roomType == PmRoomType.group) {
      return F.GROUP_UNREAD;
    }
    return F.PRIVATE_UNREAD;
  }

  /// Updates the unread message count for a specific user in a chat room.
  ///
  /// [operation] usage = 'add', 'subtract', or 'reset'.
  void updateUnreadCount({required PmRoom room, required String userId, required String operation, WriteBatch? writeBatch}) async {
    // Check if the user is a member of the room
    if (!room.users.contains(userId)) throw Exception('User $userId is not a member of room ${room.id}.');

    final unreadField = getUnreadField(room);

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
      case 'subtract':
        updateData = {
          '$unreadField.$userId': FieldValue.increment(-1),
        };
        break;
      case 'reset':
        updateData = {
          '$unreadField.$userId': 0,
        };
        break;
      default:
        throw Exception('Invalid operation: $operation. Use "add", "subtract", or "reset".');
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
}
