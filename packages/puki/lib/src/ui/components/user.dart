part of 'component.dart';

class _UserWidget {
  String? memberTypingStatus(List<PmUser?> users, String roomId) {
    List<PmUser?> members = List.from(users);

    members.removeWhere((e) => e!.id == Puki.user.currentUser!.id);

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
      status = 'Never Seen';
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
    return CustomCircleAvatar(
      firstLetterAvatar: user.firstName[0].toUpperCase(),
      imageUrl: user.avatar,
    );
  }

  Widget circleAvatar(PmUser? user, {double? radius, Color? backgroundColor, Color? foregroundColor}) {
    if (user == null || user.isDeleted) {
      return CircleAvatar(backgroundColor: Colors.grey);
    }

    return Builder(
      builder: (context) {
        final ThemeData theme = Theme.of(context);
        TextStyle textStyle = theme.primaryTextTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600);
        Color? effectiveBackgroundColor = backgroundColor;

        if (effectiveBackgroundColor == null) {
          switch (ThemeData.estimateBrightnessForColor(textStyle.color!)) {
            case Brightness.dark:
              effectiveBackgroundColor = theme.primaryColorLight;
              break;
            case Brightness.light:
              effectiveBackgroundColor = theme.primaryColorDark;
              break;
          }
        } else if (foregroundColor == null) {
          switch (ThemeData.estimateBrightnessForColor(backgroundColor!)) {
            case Brightness.dark:
              textStyle = textStyle.copyWith(color: theme.primaryColorLight);
              break;
            case Brightness.light:
              textStyle = textStyle.copyWith(color: theme.primaryColorDark);
              break;
          }
        }

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveBackgroundColor,
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 0.2, blurRadius: 0.7, offset: const Offset(0, 1)),
            ],
          ),
          child: ClipOval(
            child: user.avatar.isEmpty
                ? Container(alignment: Alignment.center, child: Text(user.name[0].toUpperCase(), style: textStyle))
                : Image.network(
                    user.avatar,
                    errorBuilder: (context, url, error) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(child: Icon(Icons.broken_image_sharp, color: Colors.grey[400])),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
