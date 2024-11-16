// coverage:ignore-file

import 'package:puki/puki.dart';
import 'package:puki/src/ui/controllers/controller.dart';

class PukiUi {
  static final PukiUi _instance = PukiUi._internal();

  factory PukiUi() {
    return _instance;
  }

  PukiUi._internal();

  static Future<void> sendCustomMessage({required PmRoom room, required PmContent content}) async {
    await Controller.message.sendMessage(room: room, content: content);
  }
}
