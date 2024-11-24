import 'package:puki/src/ui/controllers/chat.dart';
import 'package:puki/src/ui/controllers/input.dart';
import 'package:puki/src/ui/controllers/message.dart';
import 'package:puki/src/ui/controllers/room.dart';

class Controller {
  static final _instance = Controller._internal();

  factory Controller() => _instance;

  Controller._internal();

  static final ChatRoomController chatRoom = ChatRoomController();
  static final MessageController message = MessageController();
  static final RoomController room = RoomController();
  static final InputController input = InputController();

  static void dispose() {
    input.reset();
    chatRoom.reset();
    message.reset();
  }
}
