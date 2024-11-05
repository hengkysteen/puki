import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class UsersCollection extends BaseCollection {
  final FirebaseFirestore _firestore;

  UsersCollection(this._firestore) : super();

  CollectionReference<Map<String, dynamic>> get collection => _firestore.collection(settings.getCollectionPath("users"));
}
