import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/helper/log.dart';
import 'package:puki/src/core/core.dart';

class InputController {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();

  bool isTyping = false;

  static final List<PmInputType?> _inputTypes = [];

  List<PmInputType?> get inputTypes => _inputTypes;

  static PmUser? get currentUser => PukiCore.user.currentUser;

  void addInputs(List<PmInputType> data) {
    final checkTypes = <String>{};

    for (var input in data) {
      if (!checkTypes.add(input.type)) {
        throw Exception("Duplicate type found: ${input.type}");
      }
      if (input.type == "text") {
        throw Exception("Text is a default system type and cannot be added");
      }
    }
    _inputTypes.clear();
    _inputTypes.addAll(data);
    _inputTypes.sort((a, b) => a!.name.compareTo(b!.name));

    devLog("InputController > addInputs ${_inputTypes.map((e) => e!.name).toList()}");
  }

  void onTyping(String txt, String roomId) {
    if (txt.isNotEmpty) {
      if (isTyping == false) {
        PukiCore.firestore.user.setTypingStatus(userId: currentUser!.id, status: true, roomId: roomId);
        setIsTyping(true);
      }
    } else {
      PukiCore.firestore.user.setTypingStatus(userId: currentUser!.id, status: false, roomId: roomId);
      setIsTyping(false);
    }
  }

  void setIsTyping(bool value) {
    isTyping = value;
  }

  PmInputType? getInputTypeFromContentType(String? contentType) {
    return inputTypes.firstWhere((e) => e!.type == contentType, orElse: () => null);
  }

  void reset() {
    if (isTyping) {
      isTyping = false;
      PukiCore.firestore.user.setTypingStatus(userId: currentUser!.id, status: false, roomId: null);
    }
    textController.clear();
  }
}
