// coverage:ignore-file

class PmUser {
  late String id;
  late String name;
  late String email;
  late String avatar;
  final PmTyping? typing;
  final PmOnline? online;
  final Map<String, dynamic>? userData;
  bool isDeleted;

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

  factory PmUser.fromJson(Map<String, dynamic> json) => PmUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        avatar: json['avatar'] as String,
        typing: json['typing'] == null ? null : PmTyping.fromJson(json['typing'] as Map<String, dynamic>),
        online: json['online'] == null ? null : PmOnline.fromJson(json['online'] as Map<String, dynamic>),
        userData: json['user_data'] as Map<String, dynamic>?,
        isDeleted: json['is_deleted'] as bool,
      );

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
