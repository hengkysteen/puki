import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/helper/log.dart';

class InputController extends GetxController {
  List<PmInputType?> inputTypes = [];
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();
  bool isTyping = false;
  PmInputType? inputType;

  static PmUser? get currentUser => Puki.user.currentUser;

  PmInputType? getInputTypeFromContentType(String? contentType) {
    return inputTypes.firstWhere((e) => e!.type == contentType, orElse: () => null);
  }

  void addNewInput(List<PmInputType> data) {
    inputTypes.clear();
    inputTypes.addAll(data);
    List inputs = [];

    for (var type in inputTypes) {
      inputs.add(type!.name);
    }
    devLog("InputVm > addNewInput $inputs");
  }

  void setInputType(PmInputType? type) {
    inputType = type;
    update();
  }

  void onTyping(String txt, String roomId) {
    if (txt.isNotEmpty) {
      if (isTyping == false) {
        Puki.firestore.user.setTypingStatus(userId: currentUser!.id, status: true, roomId: roomId);
        setIsTyping(true);
      }
    } else {
      Puki.firestore.user.setTypingStatus(userId: currentUser!.id, status: false, roomId: roomId);
      setIsTyping(false);
    }
  }

  void setIsTyping(bool value) {
    isTyping = value;
    update();
  }

  @override
  void onClose() {
    if (isTyping) {
      isTyping = false;
      Puki.firestore.user.setTypingStatus(userId: currentUser!.id, status: false, roomId: null);
    }
    textController.clear();
    focusNode.dispose();
    super.onClose();
  }
}
