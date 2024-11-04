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
  Future<PmMessage?> getMessageById(String messageId) async {
    final data = await collection.doc(messageId).get();
    return data.exists ? PmMessage.fromJson(data.data()!) : null;
  }
}
