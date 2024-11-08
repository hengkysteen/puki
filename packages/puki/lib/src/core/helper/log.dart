// coverage:ignore-file

import 'dart:developer';
import 'package:puki/src/core/settings/settings.dart';

void devLog(String msg) {
  if (PukiSettings().client.showDevLog) {
    log(msg, name: "Puki");
  }
}
