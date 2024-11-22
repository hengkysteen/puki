import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/components/component.dart';
import 'package:wee_kit/wee_kit.dart';

class GroupTitle extends StatelessWidget {
  final PmChat chatData;
  const GroupTitle({super.key, required this.chatData});

  String _membersSeparator(List<String> names) {
    if (names.isEmpty) return "";

    if (names.length == 1) {
      return names.first;
    } else if (names.length == 2) {
      return '${names[0]} & ${names[1]}';
    } else {
      // Gabungkan semua kecuali yang terakhir, dan tambahkan ' & ' di depan nama terakhir
      final allExceptLast = names.sublist(0, names.length - 1).join(', ');
      return '$allExceptLast & ${names.last}';
    }
  }

  List<String> _getGroupMembersName(List<PmUser> users, PmRoom room) {
    // Get the active members from the room
    List<String> members = users.map((user) => user.name.split(" ")[0]).toList();

    // Sort the names alphabetically in reverse order
    members.sort((a, b) => b.compareTo(a));

    // Remove the current user's name from the list
    members.remove(PukiCore.user.currentUser!.firstName.toCapitalize());

    // Add "You" to the list to represent the current user
    members.add("You");

    // Return the members' names in the desired order
    return members.reversed.toList();
  }

  Widget membersName(List<PmUser> users, PmRoom room) {
    final members = _getGroupMembersName(users, room);

    late String text;

    if (members.isNotEmpty && members.length <= 4) {
      return Row(
        children: List.generate(_membersSeparator(members).length, (i) {
          return Text(_membersSeparator(members)[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal));
        }),
      );
    }

    final memberTyping = PukiComp.user.memberTypingStatus(chatData.members, chatData.room!.id);

    if (memberTyping != null) {
      text = memberTyping;
    } else {
      text = '${members.length} members';
    }

    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            chatData.room!.group!.name,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          membersName(chatData.members, chatData.room!),
        ],
      ),
    );
  }
}
