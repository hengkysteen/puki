// coverage:ignore-file
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class PmMessage {
  late final String id;
  late final String sender;
  late final String roomId;
  late final String roomType;
  late final Timestamp date;
  late final int status;
  late final PmContent content;
  late final bool isSystem;
  late final List<dynamic> users;
  late final List<PmReadBy?> readBy;
  late final List<String> visibleTo;
  PmReply? reply;

  PmMessage({
    required this.id,
    required this.sender,
    required this.roomId,
    required this.roomType,
    required this.date,
    this.status = 0,
    required this.content,
    this.isSystem = false,
    required this.users,
    required this.readBy,
    this.visibleTo = const [],
    this.reply,
  });

  PmMessage.fromJson(Map<String, dynamic> json) {
    content = PmContent.fromJson(json['content']);
    sender = json['sender'];
    roomId = json['room_id'];
    roomType = json['room_type'];
    date = json['date'];
    users = json['users'];
    status = json['status'];
    id = json['id'];
    isSystem = json['is_system'];
    readBy = json['read_by'].isEmpty ? <PmReadBy?>[] : json['read_by'].map<PmReadBy?>((e) => PmReadBy.fromJson(e)).toList();
    visibleTo = List<String>.from(json['visible_to']);
    reply = json['reply'] == null ? null : PmReply.fromJson(json['reply']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content.toJson();
    data['sender'] = sender;
    data['room_id'] = roomId;
    data['room_type'] = roomType;
    data['date'] = date;
    data['users'] = users;
    data['status'] = status;
    data['id'] = id;
    data['is_system'] = isSystem;
    data['read_by'] = readBy.map((v) => v!.toJson()).toList();
    data['visible_to'] = visibleTo;
    data['reply'] = reply?.toJson();
    return data;
  }
}

/// PmContent Model. part of [PmMessage]
class PmContent {
  late final String message;
  late final String type;
  late final bool deleted;
  Map<String, dynamic>? customData;
  PmContent({required this.type, required this.message, this.deleted = false, this.customData});
  PmContent.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    message = json['message'];
    deleted = json['deleted'];
    customData = json['custom_data'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['message'] = message;
    data['deleted'] = deleted;
    data['custom_data'] = customData;
    return data;
  }
}

/// PmReadBy Model. part of [PmMessage]
class PmReadBy {
  late final String user;
  late final Timestamp time;
  PmReadBy({required this.user, required this.time});
  PmReadBy.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    time = json['time'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['time'] = time;
    return data;
  }
}

/// Replied Model. part of [PmMessage]
class PmReply {
  late final String messageId;
  late final PmContent messageContent;
  late final String messageOwner;
  PmReply({required this.messageId, required this.messageOwner, required this.messageContent});
  PmReply.fromJson(Map<String, dynamic> json) {
    messageId = json['message_id'];
    messageContent = PmContent.fromJson(json['message_content']);
    messageOwner = json['message_owner'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message_id'] = messageId;
    data['message_content'] = messageContent.toJson();
    data['message_owner'] = messageOwner;
    return data;
  }
}

/// Grouping list of [messages] with a date
class PmGroupingMessages {
  late String date;
  List<PmMessage>? messages;
  PmGroupingMessages({required this.date, this.messages});
  PmGroupingMessages.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    messages = (json['messages'] != null ? (json['messages'] as List).map((item) => PmMessage.fromJson(item)).toList() : null);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['messages'] = messages?.map((msg) => msg.toJson()).toList();
    return data;
  }
}
