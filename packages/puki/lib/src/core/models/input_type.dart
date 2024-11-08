// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:puki/puki.dart';

class PmInputType {
  late String name;
  IconData? icon;
  late String type;
  late bool insideBubble;
  late Widget Function(BuildContext context, PmContent content)? body;
  late Widget Function(BuildContext context, PmContent snippet)? preview;
  late void Function(BuildContext context, PmRoom room) onIconTap;
  late bool showInMenu;

  PmInputType({
    required this.name,
    this.icon,
    required this.type,
    required this.body,
    required this.preview,
    required this.onIconTap,
    this.insideBubble = true,
    this.showInMenu = true,
  });
}
