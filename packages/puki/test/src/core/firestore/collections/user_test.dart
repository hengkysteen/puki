import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/firestore/collections/message.dart';
import 'package:puki/src/core/firestore/collections/room.dart';
import 'package:puki/src/core/firestore/collections/user.dart';
import 'package:puki/src/core/helper/fields.dart';
import '../../../../data/user.dart';
part 'user_test/get_single_user.dart';
part 'user_test/stream_single_user.dart';
part 'user_test/create_user.dart';
part 'user_test/stream_all_users.dart';
part 'user_test/set_online_status.dart';
part 'user_test/set_typing_status.dart';
part 'user_test/get_all_users.dart';

final FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();

void main() {
  late final UsersCollection usersCollection;
  const String messagePath = "puki_users";

  Puki.initializeTest(
    mockFirestore: fakeFirestore,
    mockMessageCollection: MessagesCollection(fakeFirestore),
    mockRoomCollection: RoomsCollection(fakeFirestore),
    mockUserCollection: UsersCollection(fakeFirestore),
  );

  usersCollection = Puki.firestore.user;

  setUp(() async {
    // Populate the fakeFirestore with dummy users
    for (var user in dummyUsers) {
      await fakeFirestore.collection(messagePath).doc(user.id).set(user.toJson());
    }
  });

  tearDown(() async {
    await fakeFirestore.collection(messagePath).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  });

  group("UsersCollection", () {
    createUser(messagePath, usersCollection);
    getSingleUser(messagePath, usersCollection);
    getAllUsers(messagePath, usersCollection);
    streamSingleUser(messagePath, usersCollection);
    streamAllUsers(messagePath, usersCollection);
    setOnlineStatus(messagePath, usersCollection);
    setTypingStatus(messagePath, usersCollection);
  });
}
