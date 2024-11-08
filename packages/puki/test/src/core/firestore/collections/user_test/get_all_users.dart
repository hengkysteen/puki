part of '../user_test.dart';

void getAllUsers(String messagePath, UsersCollection usersCollection) {
  group("getAllUsers", () {
    test('should throw an exception when userIds is an empty list', () {
      expect(
        () => usersCollection.getAllUsers(userIds: []),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains("userIds can't be empty"))),
      );
    });

    test('should return all users when userIds is null', () async {
      // Arrange
      final expectedUsers = dummyUsers;

      // Act
      final users = await usersCollection.getAllUsers(userIds: null);

      // Assert
      expect(users.length, expectedUsers.length);
      expect(users.map((u) => u.name), containsAll(['Alice', 'Bob', 'Charlie']));
    });

    test('should return only users with specific IDs when userIds is provided', () async {
      // Arrange
      final expectedUsers = [dummyUsers[0], dummyUsers[2]]; // Alice and Charlie

      // Act
      final users = await usersCollection.getAllUsers(userIds: ['user1', 'user3']);

      // Assert
      expect(users.length, expectedUsers.length);
      expect(users.map((u) => u.name), containsAll(['Alice', 'Charlie']));
      expect(users.map((u) => u.name), isNot(contains('Bob')));
    });

    test('should filter out deleted users when showDeleted is false', () async {
      // Arrange
      final deletedUser = PmUser(id: 'user4', name: 'Deleted User', isDeleted: true);
      await fakeFirestore.collection(messagePath).doc(deletedUser.id).set(deletedUser.toJson());

      // Act: Get all users with showDeleted = false
      final usersWithoutDeleted = await usersCollection.getAllUsers(userIds: null, showDeleted: false);

      // Get all users with showDeleted = true (to compare)
      final usersWithDeleted = await usersCollection.getAllUsers(userIds: null, showDeleted: true);

      // Assert: Check that the number of users with showDeleted = false is less than the number of users with showDeleted = true
      expect(usersWithoutDeleted.length, equals(usersWithDeleted.length - 1));
    });

    test('should include deleted users when showDeleted is true', () async {
      // Arrange
      // Adding a deleted user to the dummy data
      final deletedUser = PmUser(id: 'user4', name: 'Deleted User', isDeleted: true);
      await fakeFirestore.collection(messagePath).doc(deletedUser.id).set(deletedUser.toJson());

      // Act: Get all users with showDeleted = true
      final users = await usersCollection.getAllUsers(userIds: null, showDeleted: true);

      // Assert
      expect(users.any((user) => user.id == deletedUser.id), isTrue);
    });
  });
}
