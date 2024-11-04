import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class PmRoom {
  late final String id;
  late final String type;
  late List<String> users;
  late List<UserInfo> usersInfo;
  late List<String> formerUsers;
  PmPrivate? private;
  PmGroup? group;
  PmLastMessage? lastMessage;

  PmRoom({
    required this.id,
    required this.type,
    required this.users,
    this.usersInfo = const [],
    this.formerUsers = const [],
    this.private,
    this.group,
    this.lastMessage,
  }) {
    usersInfo = users.map((userId) => UserInfo(id: userId)).toList();
  }

  PmRoomType get roomType => PmRoomTypeExtention.fromString(type);

  PmRoom.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    private = json['private'] != null ? PmPrivate.fromJson(json['private']) : null;
    group = json['group'] != null ? PmGroup.fromJson(json['group']) : null;
    lastMessage = json['last_message'] != null ? PmLastMessage.fromJson(json['last_message']) : null;
    users = List<String>.from(json['users']);
    formerUsers = List<String>.from(json['former_users']);
    usersInfo = (json['users_info'] as List).map<UserInfo>((e) => UserInfo.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['private'] = private?.toJson();
    data['group'] = group?.toJson();
    data['last_message'] = lastMessage?.toJson();
    data['users'] = users;
    data['former_users'] = formerUsers;
    data['users_info'] = usersInfo.map((v) => v.toJson()).toList();
    return data;
  }
}

class PmLastMessage {
  late String? message;
  late Timestamp time;
  late String? by;
  late String name;

  PmLastMessage({this.message, required this.time, required this.by, required this.name});

  PmLastMessage.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    time = json['time'];
    by = json['by'];
    name = json['name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['time'] = time;
    data['by'] = by;
    data['name'] = name;
    return data;
  }
}

class PmGroup {
  late String name;
  late String createdBy;
  late String logo;
  Map<String, dynamic>? unread;

  PmGroup({required this.name, required this.createdBy, this.logo = '', this.unread});

  PmGroup.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    createdBy = json['createdBy'];
    logo = json['logo'];
    unread = json['unread'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['createdBy'] = createdBy;
    data['logo'] = logo;
    data['unread'] = unread;
    return data;
  }
}

class PmPrivate {
  late final String sender;
  late final String receiver;
  Map<String, dynamic>? unread;

  PmPrivate({required this.sender, required this.receiver, this.unread});

  PmPrivate.fromJson(Map<String, dynamic> json) {
    sender = json['sender'];
    receiver = json['receiver'];
    unread = json['unread'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sender'] = sender;
    data['receiver'] = receiver;
    data['unread'] = unread;
    return data;
  }
}

class UserInfo {
  late final String id;
  late final bool isRoomMember;
  late final bool isVisible;
  late final bool isAccountDeleted;

  UserInfo({
    required this.id,
    this.isRoomMember = true,
    this.isVisible = true,
    this.isAccountDeleted = false,
  });

  UserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isRoomMember = json['is_room_member'];
    isVisible = json['is_visible'];
    isAccountDeleted = json['is_account_deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['is_room_member'] = isRoomMember;
    data['is_visible'] = isVisible;
    data['is_account_deleted'] = isAccountDeleted;
    return data;
  }
}

enum PmRoomType { private, group }

extension PmRoomTypeExtention on PmRoomType {
  static PmRoomType fromString(String type) {
    switch (type) {
      case 'private':
        return PmRoomType.private;
      case 'group':
        return PmRoomType.group;
      default:
        throw Exception('Unknown RoomType: $type');
    }
  }
}
