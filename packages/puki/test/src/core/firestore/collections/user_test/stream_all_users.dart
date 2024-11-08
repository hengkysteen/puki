part of '../user_test.dart'; // Mengimpor bagian dari file utama

void streamAllUsers(String messagePath, UsersCollection usersCollection) {
  group("streamAllUsers", () {
    test("should throw an exception when userIds is an empty list", () {
      expect(
        () => usersCollection.streamAllUsers(userIds: []),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains("userIds can't be empty"))),
      );
    });

    test("should return all users when userIds is null", () async {
      // Act
      final stream = usersCollection.streamAllUsers();
      final users = await stream.first;

      // Assert
      expect(users.length, 3); // Menyesuaikan dengan jumlah dummy users
      expect(users.map((u) => u.name), containsAll(['Alice', 'Bob', 'Charlie']));
    });

    test("should return only users with specific IDs", () async {
      // Act
      final stream = usersCollection.streamAllUsers(userIds: ['user1', 'user3']);
      final users = await stream.first;

      // Assert
      expect(users.length, 2);
      expect(users.map((u) => u.name), containsAll(['Alice', 'Charlie']));
      expect(users.map((u) => u.name), isNot(contains('Bob')));
    });
  });
}
