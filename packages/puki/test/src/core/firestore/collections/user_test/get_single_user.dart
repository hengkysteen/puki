part of '../user_test.dart';

void getSingleUser(String messagePath, UsersCollection usersCollection) {
  group("getSingleUser", () {
    test('Returns the correct user for a given ID', () async {
      // Arrange
      PmUser user = dummyUsers[0]; // user1
      // Act
      final response = await usersCollection.getSingleUser(user.id);
      // Assert
      expect(response, isA<PmUser>());
      expect(response!.name, equals("Alice"));
      expect(response.toJson(), equals(user.toJson()));
    });
    test('Returns null for non-existent user', () async {
      // Arrange
      String userId = '100';
      // Act
      final response = await usersCollection.getSingleUser(userId);
      // Assert
      expect(response, isNull);
    });
  });
}
