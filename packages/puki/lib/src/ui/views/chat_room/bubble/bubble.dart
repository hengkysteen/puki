import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/components/component.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:puki/src/ui/views/chat_room/bubble/replied.dart';

class ChatRoomBubble extends StatelessWidget {
  final PmMessage message;
  final GlobalObjectKey messageKey;
  final PmUser? messageOwner;
  final PmInputType? messageInputType;
  final PmUserInfo messageOwnerInfo;

  const ChatRoomBubble({
    super.key,
    required this.message,
    required this.messageKey,
    required this.messageOwner,
    required this.messageInputType,
    required this.messageOwnerInfo,
  });

  Color? _bubbleColor(BuildContext context, PmMessage message, PmInputType? inputType) {
    if (message.reply != null) {
      return Pc.message.getColor(context, message);
    }
    if (inputType != null) {
      return inputType.insideBubble ? Pc.message.getColor(context, message) : null;
    }
    return Pc.message.getColor(context, message);
  }

  Widget bubbleMessageContent(BuildContext context, PmInputType? inputType, PmMessage message) {
    if (inputType != null) {
      return inputType.body!(context, message.content);
    }

    if (message.content.deleted) {
      return Text(
        PukiCore.user.currentUser!.id == message.sender ? 'You deleted this message. ' : 'This message was deleted. ',
        style: TextStyle(color: Colors.grey),
      );
    }
    return Text(message.content.message);
  }

  Widget _systemMessage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(message.content.message, style: TextStyle(color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (messageOwner == null) return SizedBox();
    return ValueListenableBuilder(
      valueListenable: Controller.message.highlightedRepliedMessage,
      builder: (context, _, __) {
        if (message.isSystem) return _systemMessage();

        return Container(
          key: messageKey,
          color: Controller.message.highlightedRepliedMessage.value == message.id ? Colors.black.withOpacity(0.2) : null,
          child: GestureDetector(
            onLongPressStart: message.content.deleted ? null : (d) => Pc.message.showContextualMenus(context, d, message),
            child: Container(
              margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              alignment: Pc.message.alignment(message),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Visibility(
                    visible: message.roomType == 'group' && message.isSystem == false,
                    child: Row(
                      children: [
                        !messageOwnerInfo.isRoomMember
                            ? ClipOval(
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(Colors.grey.withOpacity(0.8), BlendMode.color),
                                  child: Pc.user.getAvatar(messageOwner),
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Pc.user.getAvatar(messageOwner),
                              ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                  SizedBox(width: 5),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: message.roomType != "private",
                        child: Text(
                          messageOwner!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: messageOwnerInfo.isRoomMember ? null : Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: Pc.message.getBubbleBorderRadius(message),
                          color: _bubbleColor(context, message, messageInputType),
                          boxShadow: Pc.message.getBoxShadow(messageInputType, message),
                        ),
                        constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width - 120)),
                        child: Column(
                          crossAxisAlignment: Pc.message.crossAxisAlignment(message),
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            BubbleReplied(message: message),
                            bubbleMessageContent(context, messageInputType, message),
                            SizedBox(height: 2),
                            Pc.message.readStatus(message),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
