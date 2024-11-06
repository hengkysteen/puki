import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/firestore/collections/room.dart';
import 'package:puki/src/core/helper/log.dart';
import '../../helper/fields.dart';
import 'base.dart';

class MessagesCollection extends BaseCollection {
  final FirebaseFirestore _firestore;

  MessagesCollection(this._firestore) : super();

  RoomsCollection get _roomsCollection => Puki.firestore.room;

  /// Message Collection Reference
  CollectionReference<Map<String, dynamic>> get collection => _firestore.collection(settings.getCollectionPath(F.MESSAGES));

  /// get single message by [messageId] return `null` if not exists
  Future<PmMessage?> getSingleMessage(String messageId) async {
    final data = await collection.doc(messageId).get();
    return data.exists ? PmMessage.fromJson(data.data()!) : null;
  }

  /// Get all messages
  Future<List<PmMessage>> getAllMessages() async {
    final data = await collection.get();
    return data.docs.map((e) => PmMessage.fromJson(e.data())).toList();
  }

  /// Get all user messages in the room
  Future<List<PmMessage>> getMyMessages({required String userId, required String roomId}) async {
    final data = await collection.orderBy(F.DATE).where(F.ROOM_ID, isEqualTo: roomId).where(F.VISIBLE_TO, arrayContains: userId).get();
    return data.docs.map((e) => PmMessage.fromJson(e.data())).toList();
  }

  /// Stream all user messages in the room
  Stream<List<PmMessage>> streamMyMessages({required String userId, required String roomId}) {
    final query = collection.orderBy(F.DATE).where(F.ROOM_ID, isEqualTo: roomId).where(F.VISIBLE_TO, arrayContains: userId);
    final data = query.snapshots();
    return data.map((e) => e.docs.map((d) => PmMessage.fromJson(d.data())).toList());
  }

  /// create a message
  Future<PmMessage> createMessage({
    required String senderId,
    required PmRoom room,
    required PmContent messageContent,
    bool isSystem = false,
    PmReply? repliedTo,
  }) async {
    if (!room.users.contains(senderId)) throw Exception("Sender ID not found in room");

    final data = PmMessage(
      isSystem: isSystem,
      roomType: room.type,
      content: messageContent,
      roomId: room.id,
      sender: senderId,
      date: Timestamp.now(),
      users: List<String>.from(room.users),
      status: !isSystem ? 0 : 2,
      id: collection.doc().id,
      readBy: [],
      visibleTo: List<String>.from(room.users),
      reply: repliedTo,
    );

    await collection.doc(data.id).set(data.toJson());

    return data;
  }

  /// Hides a list of messages in [roomId] from the specified [userId] without deleting them.
  /// This is usually used for a "clear chat" functionality.
  Future<void> hideMessages({required String userId, required String roomId, required List<PmMessage> messages}) async {
    final batch = _firestore.batch();

    for (var message in messages) {
      batch.update(collection.doc(message.id), {
        F.VISIBLE_TO: FieldValue.arrayRemove([userId])
      });
    }
    await batch.commit();
  }

  /// Delete all messages from Firestore
  Future<void> deleteMessages({List<String>? messageIds, WriteBatch? writeBatch}) async {
    final messagesToDelete = messageIds ?? (await collection.get()).docs.map((e) => e.id).toList();
    if (writeBatch != null) {
      messagesToDelete.map((id) => writeBatch.delete(collection.doc(id))).toList();
      await writeBatch.commit();
    } else {
      await Future.wait(messagesToDelete.map((id) => collection.doc(id).delete()));
    }
  }

  /// Update message status.  0 = send , 1 = sended , 2 read
  Future<void> updateStatus(String messageId, int status, {WriteBatch? writeBatch}) async {
    if (writeBatch != null) {
      return writeBatch.update(collection.doc(messageId), {F.STATUS: status});
    }
    return await collection.doc(messageId).update({F.STATUS: status});
  }

  /// Read Messages
  void readMessages({required String userId, required PmRoom room, required List<PmMessage> messages}) async {
    // Periksa jika pengguna adalah anggota dari ruangan
    if (!room.users.contains(userId)) return;

    await Future.delayed(Duration(milliseconds: 500));
    // Remove messages from the list if the message sender is the current user.
    messages.removeWhere((e) => e.sender == userId);
    // Remove messages from the list if the message is marked as a system message.
    messages.removeWhere((e) => e.isSystem == true);
    // Remove messages from the list if the current user has already read the message.
    messages.removeWhere((e) => e.readBy.any((r) => r!.user == userId));

    if (messages.isEmpty) return;

    devLog("MessagesCollection > readMessages");

    await Future.delayed(Duration(milliseconds: 500));

    final batch = _firestore.batch();

    for (var message in messages) {
      List<Map<String, dynamic>> updatedReadBy = List.from(message.readBy.map((r) => r!.toJson()));

      if (!updatedReadBy.any((entry) => entry['user'] == userId)) {
        updatedReadBy.add(PmReadBy(time: Timestamp.now(), user: userId).toJson());
      }

      batch.update(collection.doc(message.id), {F.READ_BY: updatedReadBy});

      if (room.roomType == PmRoomType.private) {
        updateStatus(message.id, 2, writeBatch: batch);
      } else {
        if ((updatedReadBy.length) == (message.users.where((e) => e != message.sender).length)) {
          updateStatus(message.id, 2, writeBatch: batch);
        }
      }

      _roomsCollection.updateUnreadCount(room: room, userId: userId, operation: "reset");
    }

    await batch.commit();
  }

  /// Send Message
  Future<void> sendMessage({required PmUser user, required PmRoom room, required PmContent content, PmReply? repliedTo, bool isSystem = false}) async {
    final message = await createMessage(senderId: user.id, room: room, messageContent: content, repliedTo: repliedTo);
    await Future.delayed(Duration(milliseconds: 500));

    if (!isSystem) {
      final batch = _firestore.batch();
      await updateStatus(message.id, 1);
      _roomsCollection.updateLastMessage(room, user, content, writeBatch: batch);
      _roomsCollection.updateUnreadCount(room: room, userId: user.id, operation: "add");
      final usersInfo = room.users.where((id) => id != user.id).map((id) => PmUserInfo(id: id, isVisible: true)).toList();
      _roomsCollection.updateUserInfo(userInfo: usersInfo, room: room, writeBatch: batch);

      batch.commit();
    }
  }
}
