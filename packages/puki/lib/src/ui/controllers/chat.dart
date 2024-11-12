import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:wee_kit/debouncer.dart';

class ChatRoomController extends GetxController {
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  StreamSubscription<PmRoom>? _roomSubscription;
  StreamSubscription<List<PmMessage>>? _messagesSubscription;
  StreamSubscription<List<PmUser>>? _usersSubscription;
  PmChat? chat;

  List<PmGroupingMessages> get dataGrouping => Controller.message.groupMessageByDate(chat!.messages);

  Future<void> setup(String? roomId, PmCreateRoom? createRoom) async {
    if (roomId != null && createRoom != null) throw Exception("Can't use both roomId and createRoom");
    isLoading = true;
    update();
    String room;
    if (roomId != null) {
      room = roomId;
    } else if (createRoom != null) {
      final data = await Controller.room.createRoom(user: Puki.user.currentUser!, createRoom: createRoom);
      room = data.id;
    } else {
      throw Exception("Either roomId or createRoom must be provided");
    }
    await startListener(room);
    await Future.delayed(Duration(milliseconds: 200));
    isLoading = false;
    update();
  }

  Future<void> startListener(String roomId) async {
    chat = PmChat(room: null, messages: [], members: [], formerMembers: []);
    update();
    _roomSubscription = Puki.firestore.room.streamSingleRoom(roomId).listen((room) async {
      chat!.room = room;
      update();
      _initializeUsersListener();
      _initializeMessagesListener();

      if (chat!.room!.formerUsers.isNotEmpty) {
        final former = await Puki.firestore.user.getAllUsers(userIds: chat!.room!.formerUsers);
        chat!.formerMembers = former;
        update();
      }
    });
  }

  void _initializeMessagesListener() {
    _messagesSubscription = Puki.firestore.message.streamMyMessages(userId: Puki.user.currentUser!.id, roomId: chat!.room!.id).listen((messages) {
      if (chat != null) {
        chat!.messages = messages;
        update();
        WeeDebouncer.executeOnce(() {
          Puki.firestore.message.readMessages(
            userId: Puki.user.currentUser!.id,
            room: chat!.room!,
            messages: List.from(chat!.messages),
          );
        });
      }
    });
  }

  void _initializeUsersListener() {
    if (chat != null) {
      _usersSubscription = Puki.firestore.user.streamAllUsers(userIds: chat!.room!.users).listen((users) {
        if (chat != null) {
          chat!.members = users;
          update();
        }
      });
    }
  }

  void reset() {
    _roomSubscription?.cancel();
    _messagesSubscription?.cancel();
    _usersSubscription?.cancel();
    isLoading = false;
    chat = null;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
