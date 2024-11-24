import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:puki/src/ui/views/chat_room/appbar/appbar.dart';
import 'package:puki/src/ui/views/chat_room/bubble/bubble.dart';
import 'package:puki/src/ui/views/chat_room/input/input.dart';

import '../../assets/assets.dart';

class PukiChatRoom extends StatefulWidget {
  final String? roomId;
  final PmCreateRoom? createRoom;
  final void Function(PmContent content)? onMessageSended;

  const PukiChatRoom({
    super.key,
    this.roomId,
    this.createRoom,
    this.onMessageSended,
  });

  @override
  State<PukiChatRoom> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<PukiChatRoom> {
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    // Controller.register();
    Controller.input.addInputs(PukiCore.settings.settings.inputTypes);
    Controller.chatRoom.setup(widget.roomId, widget.createRoom);
    Controller.chatRoom.clientCallBackOnMessageSended = widget.onMessageSended;
  }

  Widget _blankWidget({Widget? child}) {
    return Scaffold(body: Center(child: child));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.roomBackground, package: 'puki'),
          fit: BoxFit.cover,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Controller.input.focusNode.unfocus();
        },
        child: ValueListenableBuilder(
          valueListenable: Controller.chatRoom.isLoading,
          builder: (context, isLoading, __) {
            if (isLoading == true) return _blankWidget();

            return ValueListenableBuilder(
              valueListenable: Controller.chatRoom.chat,
              builder: (context, _, __) {
                if (Controller.chatRoom.chat.value == null) return _blankWidget(child: Text("Something went wrong"));

                final data = Controller.chatRoom.chat.value;

                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                  appBar: ChatRoomAppbar(data: data!),
                  body: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: Controller.chatRoom.scrollController,
                          physics: BouncingScrollPhysics(),
                          reverse: true,
                          child: Column(
                            children: List.generate(Controller.chatRoom.dataGrouping.length, (index) {
                              final groupingMessage = Controller.chatRoom.dataGrouping[index];

                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text(
                                      groupingMessage.date,
                                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                                    ),
                                  ),
                                  Column(
                                    children: List.generate(groupingMessage.messages!.length, (i) {
                                      final message = groupingMessage.messages![i];

                                      final owner = Controller.message.getMessageOwner(message.sender, Controller.chatRoom.chat.value!);

                                      if (owner == null) return SizedBox();

                                      return ChatRoomBubble(
                                        message: message,
                                        messageKey: Controller.message.messageKeys.firstWhere((e) => e.value == message.id),
                                        messageOwner: owner,
                                        messageInputType: Controller.input.getInputTypeFromContentType(message.content.type),
                                        messageOwnerInfo: Controller.message.getMessageOwnerInfo(message.sender, data.room!.usersInfo),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      ChatRoomInput(room: Controller.chatRoom.chat.value!.room, onMessageSend: widget.onMessageSended)
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    Controller.dispose();
  }
}
