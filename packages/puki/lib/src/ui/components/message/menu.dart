import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:puki/src/ui/widgets/common.dart';
import 'package:wee_kit/wee_kit.dart';

mixin ContextualMenu {
  void showContextualMenus(BuildContext context, LongPressStartDetails details, PmMessage message) async {
    final menus = _getDefaultMenus(message);

    final selectedMenu = await WeeShow.contextualMenu(context: context, longPressStartDetails: details, items: menus);

    if (selectedMenu == 0) {
      _replyMessage(message);
    }
    if (selectedMenu == 1) {
      /// TODO
    }
    if (selectedMenu == 2) {
      if (!context.mounted) return;
      _copyToClipboard(context, message);
    }
    if (selectedMenu == 3) {
      _deleteMessage(message);
    }
  }

  List<PopupMenuItem<int>> _getDefaultMenus(PmMessage message) {
    final now = DateTime.now();
    final difference = now.difference(message.date.toDate());

    // all menus
    List<PopupMenuItem<int>> menus = [
      PopupMenuItem<int>(value: 0, child: _contextMenuTile('Reply', Icons.replay)),
      PopupMenuItem(value: 1, child: _contextMenuTile('Info', Icons.info_outline)),
      PopupMenuItem(value: 2, child: _contextMenuTile('Copy', Icons.copy)),
      PopupMenuItem(value: 3, child: _contextMenuTile('Delete', Icons.delete_outline)),
    ];

    // Filtering menus

    // if current user not sender show only PmReply and copy
    if (PukiCore.user.currentUser!.id != message.sender) {
      menus = menus.where((menu) => menu.value == 0 || menu.value == 2).toList();
    }
    // remove "menu copy" if type not text
    if (message.content.type != 'text') {
      menus.removeWhere((e) => e.value == 2);
    }
    // remove "menu delete" if past one minute
    if (difference.inMinutes >= 1 || message.content.deleted) {
      menus.removeWhere((e) => e.value == 3);
    }

    return menus;
  }

  void _deleteMessage(PmMessage message) => Controller.message.deleteMessage(message);

  void _copyToClipboard(BuildContext context, PmMessage message) {
    Clipboard.setData(ClipboardData(text: message.content.message.trim()));
    showSnackBar(context, 'Message Copied');
  }

  void _replyMessage(PmMessage message) async {
    await Future.delayed(Duration(milliseconds: 300));
    Controller.chatRoom.scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    Controller.message.setRepliedMessage(message);
    Controller.input.focusNode.requestFocus();
  }

  Widget _contextMenuTile(String name, IconData icons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(name, style: TextStyle(fontSize: 14)), Icon(icons, size: 15)],
    );
  }
}
