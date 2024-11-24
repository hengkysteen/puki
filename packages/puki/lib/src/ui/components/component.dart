import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/components/message/menu.dart';
import 'package:puki/src/ui/widgets/common.dart';
import 'package:puki/src/ui/widgets/custom_cirle_avatar.dart';
import 'package:wee_kit/wee_kit.dart';

part 'user.dart';
part 'room.dart';
part 'message/message.dart';
part 'input.dart';

class Pc {
  static final Pc _instance = Pc._internal();

  Pc._internal();

  factory Pc() {
    return _instance;
  }

  static final user = _UserWidget();
  static final room = _RoomWidget();
  static final message = _MessageWidget();
  static final input = _InputWidget();
}
