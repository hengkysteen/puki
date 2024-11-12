part of 'component.dart';

class _MessageWidget {
  Widget contextMenuTile(String name, IconData icons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: TextStyle(fontSize: 14)),
        Icon(icons, size: 15),
      ],
    );
  }

  Future<int?>? showContextMenus(BuildContext context, LongPressStartDetails longPress, List<PopupMenuItem<int>> menus, PmMessage message) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromLTRB(
      longPress.globalPosition.dx,
      longPress.globalPosition.dy,
      overlay.size.width - longPress.globalPosition.dx,
      overlay.size.height - longPress.globalPosition.dy,
    );
    final value = await showMenu(context: context, position: position, constraints: BoxConstraints(maxWidth: 150, minWidth: 150), items: menus);
    return value;
  }

  AlignmentGeometry alignment(PmMessage message) {
    if (message.isSystem) return Alignment.center;
    if (message.roomType == 'private') {
      return message.sender == Puki.user.currentUser!.id ? Alignment.centerRight : Alignment.centerLeft;
    }
    return Alignment.centerLeft;
  }

  CrossAxisAlignment crossAxisAlignment(PmMessage message) {
    if (message.roomType == 'private') {
      return message.sender == Puki.user.currentUser!.id ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    }
    return CrossAxisAlignment.start;
  }

  // Color? getColor(BuildContext context, PmMessage message) {
  //   final theme = Theme.of(context);
  //   if (message.sender == Puki.user.currentUser!.id) {
  //     if (theme.useMaterial3) {
  //       return WeeColor.shadeColor(Theme.of(context).colorScheme.primary, 40);
  //     } else {
  //       return Theme.of(context).primaryColor;
  //     }
  //   } else {
  //     if (theme.useMaterial3) {
  //       return WeeColor.shadeColor(Theme.of(context).colorScheme.primary, 20);
  //     } else {
  //       return Theme.of(context).cardColor;
  //     }
  //   }
  // }

  Color getColor(BuildContext context, PmMessage message) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    Color primaryColor;
    if (theme.useMaterial3) {
      // Material 3
      primaryColor = theme.colorScheme.primary;
    } else {
      // Material 2
      primaryColor = theme.primaryColor;
    }

    if (message.sender == Puki.user.currentUser!.id) {
      return brightness == Brightness.light ? WeeColor.shadeColor(primaryColor, 20) : theme.colorScheme.onPrimary;
    } else {
      return brightness == Brightness.light ? Colors.white : Colors.black;
    }
  }

  Color? getReplayColor(BuildContext context, PmMessage message) {
    if (message.sender == Puki.user.currentUser!.id) return WeeColor.shadeColor(getPrimaryColor(context), 30);
    return Colors.grey.shade50;
  }

  Color getShadeColor(Color color, int shade) {
    return WeeColor.shadeColor(color, shade);
  }

  IconData _readIcon(int? status) {
    if (status == 0) return Icons.done;
    if (status == 1) return Icons.done_all;
    if (status == 2) return Icons.done_all;
    return Icons.done;
  }

  static Color _readColor(int? status) {
    if (status == 0) return Colors.grey;
    if (status == 1) return Colors.grey;
    if (status == 2) return Colors.green;
    return Colors.grey;
  }

  Widget readStatus(PmMessage message, {bool showTime = true}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: showTime,
          child: Text("${WeeDateTime.dateToString(message.date.toDate(), "HH:mm")} ", style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ),
        Visibility(
          visible: message.content.deleted == false && message.isSystem == false,
          child: Icon(_readIcon(message.status), color: _readColor(message.status), size: 9),
        )
      ],
    );
  }

  BorderRadiusGeometry getBubbleBorderRadius(PmMessage message) {
    if (message.roomType == "group") {
      return BorderRadius.only(
        topLeft: const Radius.circular(0),
        topRight: const Radius.circular(10),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      );
    }
    return BorderRadius.only(
      bottomLeft: const Radius.circular(10),
      bottomRight: const Radius.circular(10),
      topLeft: Radius.circular(message.sender == Puki.user.currentUser!.id ? 10 : 0),
      topRight: Radius.circular(message.sender == Puki.user.currentUser!.id ? 0 : 10),
    );
  }

  List<BoxShadow>? getBoxShadow(PmInputType? messageInputType, PmMessage message) {
    //  messageInputType is null
    final isMessageInputTypeNull = messageInputType == null;

    //   messageInputType is not null but insideBubble is true
    final isInsideBubble = messageInputType?.insideBubble ?? false;

    //   message.reply is not null
    final hasReply = message.reply != null;

    // Only return shadow if one of the above conditions is met
    if (isMessageInputTypeNull || isInsideBubble || hasReply) {
      return [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 0.1,
          blurRadius: 0.3,
          offset: const Offset(0, 1),
        ),
      ];
    }

    return null;
  }
}
