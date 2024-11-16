import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/ui/components/component.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:puki/src/ui/views/chat_room/input/reply_preview.dart';

class ChatRoomInput extends StatelessWidget {
  final PmRoom? room;
  final void Function(PmContent content)? onMessageSend;

  const ChatRoomInput({super.key, required this.room, required this.onMessageSend});

  Widget widgetInputType(BuildContext context) {
    if (Controller.input.inputTypes.isEmpty) {
      return SizedBox(width: 15);
    }
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        PukiComp.input.showInputTypeMenus(
          context: context,
          types: Controller.input.inputTypes,
          onSelect: (type) {
            Navigator.pop(context);
            type.onIconTap(context, room!);
          },
        );
      },
    );
  }

  Widget widgetSendMessage(BuildContext context) {
    return SizedBox(
      width: 60,
      child: IconButton(
        icon: const Icon(Icons.send),
        onPressed: () async {
          if (!context.mounted) return;
          final text = Controller.input.textController.text;
          await Controller.message.sendMessage(room: room!, content: PmContent(type: "text", message: text));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          ChatRoomInputReplyPreview(),
          // TODO INITIAL CONTENT HERE
          Container(
            padding: EdgeInsets.only(bottom: 8, top: 8),
            color: Theme.of(context).cardColor,
            child: Row(
              children: <Widget>[
                widgetInputType(context),
                Expanded(
                  child: PukiComp.input.textField(
                    controller: Controller.input.textController,
                    focusNode: Controller.input.focusNode,
                    hintText: 'Message',
                    onChanged: (v) => Controller.input.onTyping(v, room!.id),
                  ),
                ),
                widgetSendMessage(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
