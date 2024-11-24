part of 'component.dart';

class _RoomWidget {
  Widget groupAvatar(PmGroup group, {bool showShadow = true}) {
    return CustomCircleAvatar(
      firstLetterAvatar: group.name[0].toUpperCase(),
      imageUrl: group.logo,
      showShadow: showShadow,
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
    final unread = room.unreadData![PukiCore.user.currentUser!.id];

    return Builder(builder: (context) {
      return Badge.count(
        smallSize: 16,
        count: unread!,
        backgroundColor: getPrimaryColor(context),
        isLabelVisible: room.lastMessage!.by != PukiCore.user.currentUser!.id && unread > 0,
      );
    });
  }
}
