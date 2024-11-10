// coverage:ignore-file

import 'index.dart';

class PmChat {
  PmRoom? room;
  List<PmMessage> messages;
  List<PmUser> members;
  List<PmUser> formerMembers;

  PmChat({
    required this.room,
    required this.messages,
    required this.members,
    this.formerMembers = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'room': room!.toJson(),
      'messages': messages.map((message) => message.toJson()).toList(),
      'members': members.map((user) => user.toJson()).toList(),
      'former_members': formerMembers.map((fUser) => fUser.toJson()).toList(),
    };
  }
}
