part of '../user_test.dart';

void setOnlineStatus(String messagePath, UsersCollection usersCollection) {
  group("setOnlineStatus", () {
    test('should update online status for a user', () async {
      // Arrange
      const userId = 'user1';
      const initialStatus = false;
      const updatedStatus = true;

      // Set the initial status (offline)
      await usersCollection.setOnlineStatus(userId: userId, status: initialStatus);

      // Act: Update the user's status to online
      await usersCollection.setOnlineStatus(userId: userId, status: updatedStatus);

      // Assert: Verify the status is updated
      final snapshot = await fakeFirestore.collection(messagePath).doc(userId).get();
      final onlineStatus = snapshot.data()?[F.ONLINE];

      expect(onlineStatus, isNotNull);
      expect(onlineStatus?[F.STATUS], updatedStatus);
    });
  });
}
