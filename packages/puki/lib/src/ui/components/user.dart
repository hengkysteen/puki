part of 'component.dart';

class _UserWidget {
  String? memberTypingStatus(List<PmUser?> users, String roomId) {
    List<PmUser?> members = List.from(users);

    members.removeWhere((e) => e!.id == PukiCore.user.currentUser!.id);

    final List<String> typingUsers = [];

    for (var user in members) {
      if (user != null && user.typing != null) {
        if (user.typing!.roomId == roomId && user.typing!.status == true) {
          final firstName = user.name.split(" ").first.toCapitalize();
          typingUsers.add(firstName);
        }
      }
    }

    final int count = typingUsers.length;

    if (count == 0) {
      return null;
    } else if (count == 1) {
      return "${typingUsers.first} is typing ...";
    } else if (count == 2) {
      return "${typingUsers.join(' & ')} are typing ...";
    } else {
      return "${typingUsers.take(3).join(', ')}, & ${count - 3} others are typing ...";
    }
  }

  String onlineStatusWithTyping(PmRoom room, PmUser user, {bool formatLastSeen = true}) {
    String status = "";

    if (room.id == user.typing?.roomId && user.typing!.status!) {
      status = 'typing ...';
    } else if (user.online == null) {
      status = '';
    } else if (user.online!.status!) {
      status = 'online';
    } else {
      final lSeen = formatLastSeen ? WeeDateTime.toTimeAgo(user.online!.lastSeen!.toDate()) : user.online!.lastSeen!.toDate();
      status = 'last seen $lSeen';
    }
    return status;
  }

  String onlineStatus(PmUser user, {bool formatLastSeen = true}) {
    final lSeen = formatLastSeen ? WeeDateTime.toTimeAgo(user.online!.lastSeen!.toDate()) : user.online!.lastSeen!.toDate();
    final status = user.online!.status! ? 'online' : 'last seen $lSeen';
    return status;
  }

  Widget getAvatar(PmUser? user) {
    if (user == null || user.isDeleted) {
      return CircleAvatar(backgroundColor: Colors.grey);
    }
    return CustomCircleAvatar(firstLetterAvatar: user.firstName[0].toUpperCase(), imageUrl: user.avatar);
  }
}
