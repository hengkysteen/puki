part of 'component.dart';

class _RoomWidget {
  Widget groupAvatar(PmGroup group) {
    return CustomCircleAvatar(
      firstLetterAvatar: group.name[0].toUpperCase(),
      imageUrl: group.logo,
    );
  }

  Widget unreadXlastMessageTime(PmRoom room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(WeeDateTime.toTimeAgo(room.lastMessage!.time.toDate())),
        const SizedBox(height: 5),
        unreadBadge(room),
      ],
    );
  }

  Widget unreadBadge(PmRoom room) {
    validateCurrentUser();
    final unread = room.unreadData![Puki.user.currentUser!.id];
    return Builder(builder: (context) {
      return Badge.count(
        count: 1000,
        backgroundColor: getPrimaryColor(context),
        isLabelVisible: room.lastMessage!.by != Puki.user.currentUser!.id && unread! > 0,
      );
    });
  }
}
