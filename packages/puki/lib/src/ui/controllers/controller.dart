import 'package:get/get.dart';
import 'package:puki/src/ui/controllers/chat.dart';
import 'package:puki/src/ui/controllers/input.dart';
import 'package:puki/src/ui/controllers/message.dart';
import 'package:puki/src/ui/controllers/room.dart';

class Controller {
  static final _instance = Controller._internal();

  factory Controller() => _instance;

  Controller._internal();

  static ChatRoomController get chatRoom => Get.find<ChatRoomController>();
  static RoomController get room => Get.find<RoomController>();
  static MessageController get message => Get.find<MessageController>();
  static InputController get input => Get.find<InputController>();

  static void register() {
    Get.isLogEnable = true;
    Get.put(ChatRoomController());
    Get.put(RoomController());
    Get.put(MessageController());

    if (!Get.isRegistered<InputController>()) {
      Get.put(InputController());
    }
  }

  static void remove() {
    Get.delete<ChatRoomController>();
    Get.delete<RoomController>();
    Get.delete<MessageController>();
    Get.delete<InputController>();
  }
}
