import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/ui/utils/validators.dart';
import 'package:puki/src/ui/widgets/common.dart';
import 'package:puki/src/ui/widgets/custom_cirle_avatar.dart';
import 'package:wee_kit/wee_kit.dart';

part 'user.dart';
part 'room.dart';

class PukiComp {
  static final PukiComp _instance = PukiComp._internal();

  PukiComp._internal();

  factory PukiComp() {
    return _instance;
  }

  static final user = _UserWidget();
  static final room = _RoomWidget();
}
