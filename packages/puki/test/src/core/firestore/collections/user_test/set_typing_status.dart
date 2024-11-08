part of '../user_test.dart';

void setTypingStatus(String messagePath, UsersCollection usersCollection) {
  group("setTypingStatus", () {
    test('should update typing status for a user', () async {
      // Arrange
      const userId = 'user1';
      const roomId = 'room1';
      const initialStatus = false;
      const updatedStatus = true;

      // Set the initial typing status (not typing)
      await usersCollection.setTypingStatus(userId: userId, roomId: roomId, status: initialStatus);
      
      // Act: Update the user's typing status to typing
      await usersCollection.setTypingStatus(userId: userId, roomId: roomId, status: updatedStatus);
      
      // Assert: Verify the typing status is updated
      final snapshot = await fakeFirestore.collection(messagePath).doc(userId).get();
      final typingStatus = snapshot.data()?[F.TYPING];
      
      expect(typingStatus, isNotNull);
      expect(typingStatus?[F.STATUS], updatedStatus);
      expect(typingStatus?[F.ROOM_ID], roomId);
    });

    test('should update typing status with batch operation', () async {
      // Arrange
      const userId = 'user2';
      const roomId = 'room2';
      const updatedStatus = true;
      final writeBatch = fakeFirestore.batch();

      // Act: Update the typing status with a batch operation
      await usersCollection.setTypingStatus(
        userId: userId, roomId: roomId, status: updatedStatus, writeBatch: writeBatch);
      
      // Commit the batch
      await writeBatch.commit();
      
      // Assert: Verify the typing status is updated
      final snapshot = await fakeFirestore.collection(messagePath).doc(userId).get();
      final typingStatus = snapshot.data()?[F.TYPING];
      
      expect(typingStatus, isNotNull);
      expect(typingStatus?[F.STATUS], updatedStatus);
      expect(typingStatus?[F.ROOM_ID], roomId);
    });
  });
}