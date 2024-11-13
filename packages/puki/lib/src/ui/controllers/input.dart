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
    // Create a set to store unique types
    final existingTypes = inputTypes.map((e) => e!.type).toSet();

    // Filter new data, ensuring there are no duplicate types
    for (var item in data) {
      if (existingTypes.contains(item.type)) {
        throw ArgumentError("Type '${item.type}' already exists. Each type must be unique.");
      }
    }
    inputTypes.clear();
    inputTypes.addAll(data);
    inputTypes.sort((a, b) => a!.name.compareTo(b!.name));
    devLog("InputVm > addNewInput ${inputTypes.map((e) => e!.name).toList()}");
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
