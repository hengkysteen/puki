import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/ui/components/component.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:puki/src/ui/controllers/message.dart';

class ChatRoomInputReplyPreview extends StatelessWidget {
  const ChatRoomInputReplyPreview({super.key});

  Widget? typePreview(BuildContext context, PmInputType? inputType) {
    if (inputType == null) {
      return null;
    }
    if (inputType.preview == null) return null;
    return SizedBox(
      height: 40,
      width: 40,
      child: inputType.preview!(context, Controller.message.repliedMessage!.content),
    );
  }

  Widget content(BuildContext context, PmInputType? inputType) {
    if (inputType == null) {
      return Text(
        Controller.message.repliedMessage!.content.message.trimLeft().replaceAll(RegExp(r'\n\s*\n'), '\n'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(inputType.icon, size: 15, color: Colors.black54),
        SizedBox(width: 3),
        Text(inputType.name, style: TextStyle(color: Colors.black54, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(
      builder: (controller) {
        if (controller.repliedMessage == null) return SizedBox();
        return Container(
          margin: EdgeInsets.all(10),
          child: ListTile(
            tileColor: PukiComp.message.getShadeColor(Theme.of(context).primaryColor, 30),
            leading: typePreview(context, controller.repliedMessageInputType),
            title: Text(
              controller.repliedMessageOwner!.name,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            subtitle: content(context, controller.repliedMessageInputType),
            trailing: IconButton(
              icon: Icon(Icons.close),
              color: Theme.of(context).primaryColor,
              onPressed: () => controller.setRepliedMessage(null),
            ),
          ),
        );
      },
    );
  }
}
