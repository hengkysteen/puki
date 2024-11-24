import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/ui/components/component.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:wee_kit/wee_kit.dart';

/// A bubble that displays a replay message.
class BubbleReplied extends StatelessWidget {
  ///  message is the reply message sent from the user
  final PmMessage message;

  const BubbleReplied({super.key, required this.message});

  PmInputType? get messageInputType => Controller.input.getInputTypeFromContentType(message.content.type);

  PmInputType? get replyTo => Controller.input.getInputTypeFromContentType(message.reply!.messageContent.type);

  double minWidth(PmInputType? replyTo) {
    return replyTo != null ? 130 : 0;
  }

  Widget _replayContent(BuildContext contex) {
    if (replyTo == null) {
      return Text(
        message.reply!.messageContent.message.trimLeft().replaceAll(RegExp(r'\n\s*\n'), '\n'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, color: Colors.black54),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(replyTo!.icon, size: 14, color: Colors.black54),
        SizedBox(width: 3),
        Text(replyTo!.name, style: TextStyle(color: Colors.black54, fontSize: 13)),
      ],
    );
  }

  Widget _replayPreview(BuildContext context, PmInputType? inputType) {
    if (inputType == null) return SizedBox();
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: SizedBox(width: 50, child: inputType.preview!(context, message.reply!.messageContent)),
    );
  }

  Widget temp(BuildContext context) {
    return messageInputType == null
        ? Container(
            padding: EdgeInsets.only(right: 70),
            child: Text(message.content.message, maxLines: 1, style: TextStyle(color: Colors.transparent)),
          )
        : SizedBox(height: 0, child: messageInputType!.body!(context, message.content));
  }

  @override
  Widget build(BuildContext context) {
    // Do not display [BubbleReplay] if this message is not a reply message, or if this message has been deleted.
    if (message.reply == null || message.content.deleted) return SizedBox();

    return GestureDetector(
      onTap: () async => await scrollToMessage(context),
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth(replyTo)),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: Pc.message.getBubbleBorderRadius(message),
          color: Pc.message.getShadeColor(Theme.of(context).primaryColor, 30),
        ),
        child: Stack(
          children: [
            temp(context),
            Container(
              color: Pc.message.getShadeColor(Theme.of(context).primaryColor, 30),
              padding: EdgeInsets.all(5),
              // height: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.reply!.messageOwner.split(" ")[0], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  SizedBox(height: 1),
                  _replayContent(context),
                ],
              ),
            ),
            _replayPreview(context, replyTo),
          ],
        ),
      ),
    );
  }

  Future<void> scrollToMessage(BuildContext context) async {
    WeeDebouncer.executeOnce(() async {
      Controller.message.setHighlightedRepliedMessage("");
      final targetKey = Controller.message.messageKeys.firstWhere((e) => e.value == message.reply!.messageId).currentContext;
      try {
        await Scrollable.ensureVisible(targetKey!, duration: Duration(seconds: 1));
        Controller.message.setHighlightedRepliedMessage(message.reply!.messageId);
        await Future.delayed(Duration(seconds: 1));
        Controller.message.setHighlightedRepliedMessage("");
      } catch (e) {
        // Error
      }
    }, duration: Duration(seconds: 1));
  }
}
