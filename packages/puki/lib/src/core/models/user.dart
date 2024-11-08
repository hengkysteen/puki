// coverage:ignore-file

class PmUser {
  late String id;
  late String name;
  late String email;
  late String avatar;
  PmTyping? typing;
  PmOnline? online;
  Map<String, dynamic>? userData;
  late bool isDeleted;

  PmUser({
    required this.id,
    required this.name,
    this.email = "",
    this.avatar = "",
    this.typing,
    this.online,
    this.userData,
    this.isDeleted = false,
  });

  String get firstName => name.split(" ").first;

  PmUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    avatar = json['avatar'];
    typing = json['typing'] == null ? null : PmTyping.fromJson(json['typing']);
    online = json['online'] == null ? null : PmOnline.fromJson(json['online']);
    userData = json['user_data'];
    isDeleted = json['is_deleted'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar': avatar,
        'typing': typing?.toJson(),
        'online': online?.toJson(),
        'user_data': userData,
        'is_deleted': isDeleted,
      };
}

class PmTyping {
  final String? roomId;
  final bool? status;

  const PmTyping({this.roomId, this.status});

  factory PmTyping.fromJson(Map<String, dynamic> json) => PmTyping(roomId: json['room_id'] as String?, status: json['status'] as bool?);

  Map<String, dynamic> toJson() => {'room_id': roomId, 'status': status};

  @override
  String toString() => 'Typing(roomId: $roomId, status: $status)';
}

/// PmOnline Model. part of [PmUser]
class PmOnline {
  final String? lastSeen;
  final bool? status;

  const PmOnline({this.lastSeen, this.status});

  factory PmOnline.fromJson(Map<String, dynamic> json) => PmOnline(lastSeen: json['last_seen'] as String?, status: json['status'] as bool?);

  Map<String, dynamic> toJson() => {'last_seen': lastSeen, 'status': status};

  @override
  String toString() => 'PmOnline(lastSeen: $lastSeen, status: $status)';
}
