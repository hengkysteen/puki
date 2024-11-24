import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:puki/src/utils/list.dart';
import 'package:wee_kit/wee_kit.dart';

class MessageController {
  ValueNotifier<String> highlightedRepliedMessage = ValueNotifier<String>("");

  ValueNotifier<PmMessage?> repliedMessage = ValueNotifier<PmMessage?>(null);

  PmChat? get data => Controller.chatRoom.chat.value;

  PmUser? get repliedMessageOwner {
    PmUser? user;
    if (repliedMessage.value != null) {
      user = getMessageOwner(repliedMessage.value!.sender, data!);
    }
    return user!;
  }

  List<GlobalObjectKey> get messageKeys => data!.messages.map((e) => GlobalObjectKey(e.id)).toList();

  PmInputType? get repliedMessageInputType {
    if (repliedMessage.value == null) return null;
    return Controller.input.getInputTypeFromContentType(repliedMessage.value!.content.type);
  }

  void setHighlightedRepliedMessage(String id) {
    highlightedRepliedMessage.value = id;
  }

  PmReply? getReplyFromRepliedMessage(PmRoom? room) {
    if (repliedMessage.value == null) return null;
    return PmReply(
      messageId: repliedMessage.value!.id,
      messageOwner: repliedMessageOwner!.name,
      messageContent: repliedMessage.value!.content,
    );
  }

  void setRepliedMessage(PmMessage? message) {
    repliedMessage.value = message;
  }

  List<PmGroupingMessages> groupMessageByDate(List<PmMessage> messages) {
    Map<String, List<PmMessage>> groupedMessages = {};
    for (var message in messages) {
      String formattedDate = WeeDateTime.dateToString(message.date.toDate(), "dd MMMM, yyyy");
      if (!groupedMessages.containsKey(formattedDate)) {
        groupedMessages[formattedDate] = [];
      }
      groupedMessages[formattedDate]!.add(message);
    }
    List<PmGroupingMessages> groupedMessageList = groupedMessages.entries.map((e) => PmGroupingMessages(date: e.key, messages: e.value)).toList();
    return groupedMessageList;
  }

  void deleteMessage(PmMessage message) async {
    if (PukiCore.user.currentUser!.id == message.sender && !message.isSystem) {
      final batch = PukiCore.firestore.instance.batch();
      batch.update(PukiCore.firestore.message.collection.doc(message.id), {"content.deleted": true});
      if (message.id == Controller.chatRoom.chat.value!.messages.last.id) {
        batch.update(PukiCore.firestore.room.collection.doc(message.roomId), {"last_message.message": "This message was deleted. "});
      }
      await batch.commit();
    }
  }

  Future<void> sendMessage({required PmRoom room, required PmContent content}) async {
    if (content.type == "text") {
      if (Controller.input.textController.text.isEmpty) return;
      Controller.input.textController.clear();
    }

    Controller.chatRoom.scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

    PukiCore.firestore.message.sendMessage(
      room: room,
      user: PukiCore.user.currentUser!,
      replyTo: getReplyFromRepliedMessage(room),
      content: content,
    );

    setRepliedMessage(null);

    if (content.type == "text") {
      Controller.input.setIsTyping(false);
    }

    if (Controller.chatRoom.clientCallBackOnMessageSended != null) {
      Controller.chatRoom.clientCallBackOnMessageSended!(content);
    }
  }

  PmUser? getMessageOwner(String senderId, PmChat data) {
    PmUser? user;
    final ownerInfo = getMessageOwnerInfo(senderId, data.room!.usersInfo);
    if (ownerInfo.isRoomMember) {
      user = data.members.firstWhereOrNull((e) => e.id == senderId);
    } else {
      user = data.formerMembers.firstWhereOrNull((e) => e.id == senderId);
    }
    return user;
  }

  PmUserInfo getMessageOwnerInfo(String senderId, List<PmUserInfo> membersInfo) {
    final info = membersInfo.firstWhere((e) => e.id == senderId);
    return info;
  }

  Future<void> clearMessage(String roomId, List<PmMessage> messages) async {
    await PukiCore.firestore.message.hideMessages(userId: PukiCore.user.currentUser!.id, roomId: roomId, messages: messages);
  }

  void reset() {
    setRepliedMessage(null);
    setHighlightedRepliedMessage("");
  }
}
