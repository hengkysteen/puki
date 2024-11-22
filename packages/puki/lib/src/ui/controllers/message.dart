import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/components/component.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:wee_kit/wee_kit.dart';

class MessageController extends GetxController {
  String highlightedRepliedMessage = "";
  PmMessage? repliedMessage;

  PmChat? get data => Controller.chatRoom.chat;

  PmUser? get repliedMessageOwner {
    PmUser? user;

    if (repliedMessage != null) {
      user = getMessageOwner(repliedMessage!.sender, data!);
    }

    return user!;
  }

  List<GlobalObjectKey> get messageKeys => Controller.chatRoom.chat!.messages.map((e) => GlobalObjectKey(e.id)).toList();

  PmInputType? get repliedMessageInputType {
    if (repliedMessage == null) return null;
    return Controller.input.getInputTypeFromContentType(repliedMessage!.content.type);
  }

  void setHighlightedRepliedMessage(String id) {
    highlightedRepliedMessage = id;
    update();
  }

  PmReply? getReplyFromRepliedMessage(PmRoom? room) {
    if (repliedMessage == null) return null;
    return PmReply(
      messageId: repliedMessage!.id,
      messageOwner: repliedMessageOwner!.name,
      messageContent: repliedMessage!.content,
    );
  }

  void setRepliedMessage(PmMessage? message) {
    repliedMessage = message;
    update();
  }

  // void setMessageKeys(List<GlobalObjectKey> keys) {
  //   messageKeys = keys;
  // }

  List<PmGroupingMessages> groupMessageByDate(List<PmMessage> messages) {
    Map<String, List<PmMessage>> groupedMessages = {};

    for (var message in messages) {
      String formattedDate = WeeDateTime.dateToString(message.date.toDate(), "dd MMMM, yyyy");

      if (!groupedMessages.containsKey(formattedDate)) {
        groupedMessages[formattedDate] = [];
      }
      groupedMessages[formattedDate]!.add(message); // Tambahkan pesan ke grup
    }

    List<PmGroupingMessages> groupedMessageList = groupedMessages.entries.map((e) => PmGroupingMessages(date: e.key, messages: e.value)).toList();

    return groupedMessageList;
  }

  List<PopupMenuItem<int>> _getDefaultMenus(PmMessage message) {
    final now = DateTime.now();
    final difference = now.difference(message.date.toDate());
    //
    List<PopupMenuItem<int>> menus = [
      PopupMenuItem<int>(
        value: 0,
        child: PukiComp.message.contextMenuTile('Reply', Icons.replay),
      ),
      PopupMenuItem(
        value: 1,
        child: PukiComp.message.contextMenuTile('Info', Icons.info_outline),
      ),
      PopupMenuItem(
        value: 2,
        // enabled: message.content.type == 'text',
        child: PukiComp.message.contextMenuTile('Copy', Icons.copy),
      ),
      PopupMenuItem(
        value: 3,
        // enabled: difference.inMinutes < 1 && !message.content.deleted,
        child: PukiComp.message.contextMenuTile('Delete', Icons.delete_outline),
      ),
    ];

    // Filtering menus
    // if current user not sender show only PmReply and copy
    if (PukiCore.user.currentUser!.id != message.sender) {
      menus = menus.where((menu) => menu.value == 0 || menu.value == 2).toList();
    }
    // remove "menu copy" if type not text
    if (message.content.type != 'text') {
      menus.removeWhere((e) => e.value == 2);
    }
    // remove "menu delete" if past one minute
    if (difference.inMinutes >= 1 || message.content.deleted) {
      menus.removeWhere((e) => e.value == 3);
    }
    return menus;
  }

  void showMenus(BuildContext context, LongPressStartDetails details, PmMessage message) async {
    final menus = _getDefaultMenus(message);
    final selectedMenu = await PukiComp.message.showContextMenus(context, details, menus, message);

    //
    if (selectedMenu == 0) {
      showRepliedPreview(message);
    }
    if (selectedMenu == 1) {}
    if (selectedMenu == 2) {
      if (!context.mounted) return;
      copyToClipboard(context, message);
    }
    if (selectedMenu == 3) {
      deleteMessage(message);
    }
  }

  void showMessageInfo(BuildContext navigatorState, PmMessage message, PmRoom room) {}

  void copyToClipboard(BuildContext context, PmMessage message) {
    Clipboard.setData(ClipboardData(text: message.content.message.trim()));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Message Copied"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void showRepliedPreview(PmMessage message) async {
    await Future.delayed(Duration(milliseconds: 300));
    Controller.chatRoom.scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    setRepliedMessage(message);
    Controller.input.focusNode.requestFocus();
  }

  void deleteMessage(PmMessage message) async {
    if (PukiCore.user.currentUser!.id == message.sender && !message.isSystem) {
      final batch = PukiCore.firestore.instance.batch();
      batch.update(PukiCore.firestore.message.collection.doc(message.id), {"content.deleted": true});
      if (message.id == Controller.chatRoom.chat!.messages.last.id) {
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

    final replied = getReplyFromRepliedMessage(room);

    PukiCore.firestore.message.sendMessage(room: room, user: PukiCore.user.currentUser!, replyTo: replied, content: content);

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
      user = data.members.firstWhere((e) => e.id == senderId);
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

  @override
  void onClose() {
    setRepliedMessage(null);
    super.onClose();
  }
}
