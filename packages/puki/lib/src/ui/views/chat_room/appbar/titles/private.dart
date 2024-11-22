import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';

import '../../../../components/component.dart';

class PrivateTitle extends StatelessWidget {
  final PmChat chatData;
  const PrivateTitle({super.key, required this.chatData});

  PmUser get receiver => chatData.members.firstWhere((e) => e.id != PukiCore.user.currentUser!.id);
  String get status {
    return PukiComp.user.onlineStatusWithTyping(chatData.room!, receiver);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            receiver.name,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
          ),
          Visibility(
            visible: status.isNotEmpty,
            child: Text(
              PukiComp.user.onlineStatusWithTyping(chatData.room!, receiver),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          )
        ],
      ),
    );
  }
}
