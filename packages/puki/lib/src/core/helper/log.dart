// coverage:ignore-file

import 'dart:developer';
import 'package:puki/src/core/core.dart';

void devLog(String msg) {
  if (PukiCore.settings.settings.showDevLog) {
    log(msg, name: "Puki");
  }
}
