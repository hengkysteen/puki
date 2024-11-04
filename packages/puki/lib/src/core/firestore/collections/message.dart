import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/src/core/models/index.dart';
import '../../helper/fields.dart';
import 'base.dart';

class MessagesCollection extends BaseCollection {
  final FirebaseFirestore _firestore;

  MessagesCollection(this._firestore) : super();

  /// Message Collection Reference
  CollectionReference<Map<String, dynamic>> get collection => _firestore.collection(settings.getCollectionPath(F.MESSAGES));

  /// get single message by [messageId] return `null` if not exists
  Future<PmMessage?> getSingleMessage(String messageId) async {
    final data = await collection.doc(messageId).get();
    return data.exists ? PmMessage.fromJson(data.data()!) : null;
  }

  /// get all messages return `[]` if empty
  Future<List<PmMessage>> getAllMessages() async {
    final data = await collection.get();
    return data.docs.map((e) => PmMessage.fromJson(e.data())).toList();
  }

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
    PmReply? repliedToMessage,
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
      reply: repliedToMessage,
    );

    await collection.doc(data.id).set(data.toJson());

    return data;
  }

  /// Hides a list of messages from the specified [userId] without deleting them.
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

  /// TODO
  sendMessage() {}

  /// TODO
  readMessages() {}
}
