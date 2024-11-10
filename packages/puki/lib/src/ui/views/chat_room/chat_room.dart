import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/ui/controllers/chat.dart';
import 'package:puki/src/ui/controllers/controller.dart';

import '../../assets/assets.dart';

class PukiChatRoom extends StatefulWidget {
  final String? roomId;
  final PmCreateRoom? createRoom;
  const PukiChatRoom({super.key, this.roomId, this.createRoom});

  @override
  State<PukiChatRoom> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<PukiChatRoom> {
  @override
  void initState() {
    super.initState();
    Controller.register();
    Controller.chatRoom.setup(widget.roomId, widget.createRoom);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(Assets.roomBackground, package: 'puki'), fit: BoxFit.cover),
      ),
      child: GestureDetector(
        onTap: Controller.chatRoom.focusNode.unfocus,
        child: GetBuilder<ChatRoomController>(
          builder: (_) {
            if (Controller.chatRoom.isLoading == true) return SizedBox();

            if (Controller.chatRoom.chat == null) return SizedBox();

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              appBar: AppBar(),
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
                                child: Text(groupingMessage.date, style: TextStyle(color: Colors.grey[600])),
                              ),
                              Column(
                                children: List.generate(groupingMessage.messages!.length, (i) {
                                  final message = groupingMessage.messages![i];

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text("ID = ${message.id}"),
                                      Text("Msg = ${message.content.message}"),
                                      Text("Owner Id = ${message.sender}"),
                                      Text("Status = ${message.status}"),
                                      SizedBox(height: 20),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(child: Icon(Icons.send), onPressed: () async => await sendMessage()),
            );
          },
        ),
      ),
    );
  }

  Future<void> sendMessage() async {
    final message = Faker().lorem.sentence();

    await Puki.firestore.message.sendMessage(
      user: Puki.user.currentUser!,
      room: Controller.chatRoom.chat!.room!,
      content: PmContent(type: "text", message: message),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    Controller.remove();
  }
}
