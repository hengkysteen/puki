import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/src/core/models/index.dart';
import 'package:puki/src/core/models/room.dart';
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

  Future<PmMessage> createMessage({
    required String senderId,
    required PmRoom room,
    required PmContent messageContent,
    bool isSystem = false,
    PmReply? repliedToMessage,
  }) async {
    if (!room.users.contains(senderId)) {
      throw Exception("Sender ID not found in room");
    }

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
}
