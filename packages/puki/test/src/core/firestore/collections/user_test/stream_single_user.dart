part of '../user_test.dart';

void streamSingleUser(String messagePath, UsersCollection usersCollection) {
  group("streamSingleUser", () {
    test("should stream the correct user data for a given ID", () async {
      // Arrange
      const userId = 'user1';
      final expectedUser = dummyUsers.firstWhere((user) => user.id == userId);

      // Act
      final stream = usersCollection.streamSingleUser(userId);
      final user = await stream.first;

      // Assert
      expect(user.id, expectedUser.id);
      expect(user.name, expectedUser.name);
      expect(user.email, expectedUser.email);
    });

    test("should update stream when user data changes", () async {
      // Arrange
      const userId = 'user2';
      final originalUser = dummyUsers.firstWhere((user) => user.id == userId);
      const updatedName = "Updated Name";

      // Act
      final stream = usersCollection.streamSingleUser(userId).take(2); // Take only the first two updates

      // Listen for the initial and updated values in the stream
      expectLater(
        stream,
        emitsInOrder([
          // Expect the initial data
          isA<PmUser>().having((user) => user.name, 'name', originalUser.name),
          // Expect the updated data after change
          isA<PmUser>().having((user) => user.name, 'name', updatedName),
        ]),
      );

      // Update user data after starting the stream listener
      await fakeFirestore.collection(messagePath).doc(userId).update({'name': updatedName});

      // reset to default dummy users
      await fakeFirestore.collection(messagePath).doc(userId).update({'name': originalUser.name});
    });
  });
}
