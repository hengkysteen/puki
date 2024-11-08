part of '../user_test.dart';

void createUser(String messagePath, UsersCollection usersCollection) {
  group("createUser", () {
    test('Creates a user successfully', () async {
      // Arrange
      String userId = "1";
      PmUser user = PmUser(id: userId, name: 'John Doe', email: 'john.doe@example.com');

      // Act
      await usersCollection.createUser(user);

      // Assert
      final snapshot = await fakeFirestore.collection(messagePath).doc(userId).get();
      expect(snapshot.exists, true);
      expect(snapshot.data()!['id'], userId);
      expect(snapshot.data()!['name'], user.name);
    });
  });
}
