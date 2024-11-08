import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/firestore/collections/message.dart';
import 'package:puki/src/core/firestore/collections/room.dart';
import 'package:puki/src/core/firestore/collections/user.dart';
import '../../../../data/message.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MessagesCollection messagesCollection;
  String messagePath = "puki_messages";

  setUpAll(() async {
    fakeFirestore = FakeFirebaseFirestore();

    Puki.initializeTest(
      mockFirestore: fakeFirestore,
      mockMessageCollection: MessagesCollection(fakeFirestore),
      mockRoomCollection: RoomsCollection(fakeFirestore),
      mockUserCollection: UsersCollection(fakeFirestore),
    );

    messagesCollection = Puki.firestore.message;

    for (var message in dummyMessages) {
      await fakeFirestore.collection(messagePath).doc(message.id).set(message.toJson());
    }
  });

  group("MessageCollection", () {
    group("getSingleMessage", () {
      test('Returns the correct message for a given ID', () async {
        // Arrange
        String messageId = "1";
        await fakeFirestore.collection(messagePath).doc(messageId).set(dummyMessages[0].toJson());
        // Act
        final response = await messagesCollection.getSingleMessage(messageId);
        // Assert
        expect(response, isA<PmMessage>());
        expect(response!.toJson(), equals(dummyMessages[0].toJson()));
      });

      test('Returns null for non-existent message', () async {
        // Arrange
        String messageId = '6'; // ID that does not exist
        // Act
        final response = await messagesCollection.getSingleMessage(messageId);
        // Assert
        expect(response, isNull);
      });
    });

    group("getAllMessages", () {
      test("Return all message from firestore", () async {
        // Act
        final messages = await Puki.firestore.message.getAllMessages();
        // Assert
        expect(messages, isA<List<PmMessage>>());
      });

      test("Return empty", () async {
        //  Act remove database
        final message = await fakeFirestore.collection(messagePath).get();

        for (var message in message.docs) {
          await fakeFirestore.collection(messagePath).doc(message.id).delete();
        }
        // Act
        final messages = await Puki.firestore.message.getAllMessages();

        // Assert
        expect(messages, isEmpty);
      });
    });

    group("createMessage", () {
      test("return message if success", () async {
        // Arrange
        const senderId = "1";
        final room = PmRoom(id: "111", type: "private", users: ["1", "2"]);
        // Act
        final message = await Puki.firestore.message.createMessage(
          senderId: senderId,
          room: room,
          messageContent: PmContent(type: "text", message: "Hallo"),
        );
        //   Assert
        expect(message, isA<PmMessage>());
        expect(message.status, equals(0));
        expect(message.isSystem, equals(false));
        expect(message.reply, equals(null));
        expect(message.content.message, equals("Hallo"));
      });

      test("Throw Exception if senderId is NOT room member", () async {
        // Arrange
        const senderId = "A";
        final room = PmRoom(id: "111", type: "private", users: ["1", "2"]);

        // Act
        Future<PmMessage> createMessage() async {
          return await Puki.firestore.message.createMessage(
            senderId: senderId,
            room: room,
            messageContent: PmContent(type: "text", message: "Hallo"),
          );
        }

        Matcher errMsg = throwsA(isA<Exception>().having((e) => e.toString(), 'err message', contains("Sender ID not found in room")));

        // Assert
        expect(createMessage, errMsg);
      });
    });
  });
}
