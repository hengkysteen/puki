import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/helper/fields.dart';
import 'base.dart';

class UsersCollection extends BaseCollection {
  final FirebaseFirestore _firestore;

  UsersCollection(this._firestore) : super();

  CollectionReference<Map<String, dynamic>> get collection => _firestore.collection(settings.getCollectionPath("users"));

  Future<void> createUser(PmUser user) async => await collection.doc(user.id).set(user.toJson());

  Future<PmUser?> getSingleUser(String id) async {
    final snapshot = await collection.doc(id).get();
    return snapshot.exists ? PmUser.fromJson(snapshot.data()!) : null;
  }

  Future<List<PmUser>> getAllUsers({List<String>? userIds, bool showDeleted = false}) async {
    if (userIds != null && userIds.isEmpty) throw Exception('userIds can\'t be empty');

    late Query<Map<String, dynamic>> query;

    // If userIds is null, return all users
    if (userIds == null) {
      query = collection;
    } else {
      query = collection.where(F.ID, whereIn: userIds);
    }

    // If showDeleted is false, filter out deleted users
    if (!showDeleted) {
      query = query.where(F.IS_DELETED, isEqualTo: false);
    }

    final data = await query.get();

    // Return a list of users from the Firestore snapshot
    return data.docs.map((e) => PmUser.fromJson(e.data())).toList();
  }

  Stream<PmUser> streamSingleUser(String id) {
    final data = collection.doc(id).snapshots();
    return data.map((e) => PmUser.fromJson(e.data()!));
  }

  Stream<List<PmUser>> streamAllUsers({List<String>? userIds}) {
    if (userIds != null && userIds.isEmpty) throw Exception('userIds can\'t be empty');
    late Stream<QuerySnapshot<Map<String, dynamic>>> snapshot;
    if (userIds == null) {
      snapshot = collection.snapshots();
    } else {
      snapshot = collection.where(F.ID, whereIn: userIds).snapshots();
    }
    return snapshot.map((e) => e.docs.map((d) => PmUser.fromJson(d.data())).toList());
  }

  Future<void> setOnlineStatus({required String userId, required bool status}) async {
    final data = {F.ONLINE: PmOnline(status: status, lastSeen: DateTime.now().toString()).toJson()};
    await collection.doc(userId).update(data);
  }

  Future<void> setTypingStatus({required String userId, required String? roomId, required bool status, WriteBatch? writeBatch}) async {
    final data = {F.TYPING: PmTyping(status: status, roomId: roomId).toJson()};

    if (writeBatch == null) {
      collection.doc(userId).update(data);
    } else {
      writeBatch.update(collection.doc(userId), data);
    }
  }
}
