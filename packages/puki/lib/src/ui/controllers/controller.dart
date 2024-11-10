import 'package:get/get.dart';
import 'package:puki/src/ui/controllers/chat.dart';
import 'package:puki/src/ui/controllers/message.dart';
import 'package:puki/src/ui/controllers/room.dart';

class Controller {
  static final _instance = Controller._internal();

  factory Controller() => _instance;

  Controller._internal();

  static ChatRoomController get chatRoom => Get.find<ChatRoomController>();
  static RoomController get room => Get.find<RoomController>();
  static MessageController get message => Get.find<MessageController>();

  static void register() {
    Get.isLogEnable = true;
    Get.put(ChatRoomController());
    Get.put(RoomController());
    Get.put(MessageController());
  }

  static void remove() {
    Get.delete<ChatRoomController>();
    Get.delete<RoomController>();
    Get.delete<MessageController>();
  }
}
