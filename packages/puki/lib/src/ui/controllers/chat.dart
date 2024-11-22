import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:wee_kit/debouncer.dart';

class ChatRoomController extends GetxController {
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;

  void Function(PmContent content)? clientCallBackOnMessageSended;

  List<PmGroupingMessages> get dataGrouping => Controller.message.groupMessageByDate(chat!.messages);

  StreamSubscription<PmRoom>? _roomSubscription;

  StreamSubscription<List<PmUser>>? _usersSubscription;

  StreamSubscription<List<PmMessage>>? _messagesSubscription;

  PmChat? chat;

  void setLoading(bool value) {
    isLoading = value;
    update();
  }

  Future<void> setup(String? roomId, PmCreateRoom? createRoom) async {
    if (roomId != null && createRoom != null) throw Exception("Can't use both roomId and createRoom");
    isLoading = true;
    update();
    String room;
    if (roomId != null) {
      room = roomId;
    } else if (createRoom != null) {
      final data = await Controller.room.createRoom(user: PukiCore.user.currentUser!, createRoom: createRoom);
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

    final roomStream = PukiCore.firestore.room.streamSingleRoom(roomId);

    _roomSubscription = roomStream.listen(
      (room) {
        chat!.room = room;
        update();

        if (chat != null && chat!.room!.formerUsers.isNotEmpty) {
          PukiCore.firestore.user.getAllUsers(userIds: chat!.room!.formerUsers).then((former) {
            chat!.formerMembers = former;
            update();
          });
        }
      },
      onError: (error) {
        print('Error in room stream: $error');
      },
    );

    await roomStream.first;

    if (chat!.room != null) {
      _initializeUsersListener();
      _initializeMessagesListener();
    }
  }

  void _initializeMessagesListener() {
    _messagesSubscription = PukiCore.firestore.message.streamMyMessages(userId: PukiCore.user.currentUser!.id, roomId: chat!.room!.id).listen((messages) {
      if (chat != null) {
        chat!.messages = messages;
        update();

        WeeDebouncer.executeOnce(() {
          PukiCore.firestore.message.readMessages(
            userId: PukiCore.user.currentUser!.id,
            room: chat!.room!,
            messages: List.from(chat!.messages),
          );
        });
      }
    }, onError: (error) {
      print('Error in messages stream: $error');
    });

    update();
  }

  void _initializeUsersListener() {
    _usersSubscription = PukiCore.firestore.user.streamAllUsers(userIds: chat!.room!.users).listen((users) {
      if (chat != null) {
        chat!.members = users;
        update();
      }
    }, onError: (error) {
      print('Error in user stream: $error');
    });
  }

  void reset() {
    chat = null;
    isLoading = false;
    _roomSubscription?.cancel();
    _messagesSubscription?.cancel();
    _usersSubscription?.cancel();
    update();
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
