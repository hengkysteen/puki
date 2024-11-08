import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:wee_kit/wee_kit.dart';

part 'user.dart';

class PukiUiComp {
  static final PukiUiComp _instance = PukiUiComp._internal();

  PukiUiComp._internal();

  factory PukiUiComp() {
    return _instance;
  }

  static final user = _UserWidget();
}
