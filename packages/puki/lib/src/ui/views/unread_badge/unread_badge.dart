import 'package:flutter/material.dart';
import 'package:puki/src/core/core.dart';

/// A widget that displays a badge indicating the total number of unread messages
/// across all rooms for the current user.
///
/// This widget listens for real-time updates to show the current unread message
/// count across all rooms that the user is a part of. It can be customized with a
/// [builder] function to define the appearance of the badge, or defaults to displaying
/// a notification icon badge when unread messages are present.
class PukiUnreadBadge extends StatelessWidget {
  final Widget Function(int unreadCount)? builder;
  final VoidCallback onPressed;
  const PukiUnreadBadge({super.key, this.builder, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: PukiCore.user.currentUser == null ? Stream.empty() : PukiCore.firestore.room.streamTotalUnread(PukiCore.user.currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) throw Exception(snapshot.hasError.toString());
        if (!snapshot.hasData) return const SizedBox();
        final count = snapshot.data;

        if (builder != null) return builder!(count!);

        return IconButton(
          onPressed: onPressed,
          icon: Badge.count(
            smallSize: 16,
            largeSize: 16,
            isLabelVisible: count! > 0,
            count: count,
            child: Icon(Icons.notifications),
          ),
        );
      },
    );
  }
}
