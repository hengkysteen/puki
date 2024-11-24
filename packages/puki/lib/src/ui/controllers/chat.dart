import 'dart:async';
import 'package:flutter/material.dart';
import 'package:puki/puki.dart';
import 'package:puki/src/core/core.dart';
import 'package:puki/src/ui/controllers/controller.dart';
import 'package:wee_kit/wee_kit.dart';

class ChatRoomController {
  final ScrollController scrollController = ScrollController();

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  void Function(PmContent content)? clientCallBackOnMessageSended;

  StreamSubscription<PmRoom>? _roomSubscription;
  StreamSubscription<List<PmUser>>? _usersSubscription;
  StreamSubscription<List<PmMessage>>? _messagesSubscription;

  ValueNotifier<PmChat?> chat = ValueNotifier<PmChat?>(null);

  List<PmGroupingMessages> get dataGrouping => Controller.message.groupMessageByDate(chat.value!.messages);

  void setLoading(bool value) {
    isLoading.value = value;
  }

  Future<void> setup(String? roomId, PmCreateRoom? createRoom) async {
    if (roomId != null && createRoom != null) throw Exception("Can't use both roomId and createRoom");
    isLoading.value = true;

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
    isLoading.value = false;
  }

  Future<void> startListener(String roomId) async {
    chat.value = PmChat(
      room: null,
      messages: [],
      members: [],
      formerMembers: [],
    );

    final roomStream = PukiCore.firestore.room.streamSingleRoom(roomId);

    _roomSubscription = roomStream.listen(
      (room) {
        chat.value?.room = room;

        if (chat.value != null && chat.value!.room!.formerUsers.isNotEmpty) {
          PukiCore.firestore.user.getAllUsers(userIds: chat.value!.room!.formerUsers).then((former) {
            chat.value!.formerMembers = former;
          });
        }
      },
      onError: (error) {
        print('Error in room stream: $error');
      },
    );

    await roomStream.first;

    if (chat.value!.room != null) {
      _initializeUsersListener();
      _initializeMessagesListener();
    }
  }

  void _initializeMessagesListener() {
    _messagesSubscription = PukiCore.firestore.message.streamMyMessages(userId: PukiCore.user.currentUser!.id, roomId: chat.value!.room!.id).listen((messages) {
      if (chat.value != null) {
        // chat.value!.messages = messages;

        chat.value = PmChat(
          room: chat.value!.room,
          messages: messages,
          members: chat.value!.members,
          formerMembers: chat.value!.formerMembers,
        );

        WeeDebouncer.executeOnce(() {
          PukiCore.firestore.message.readMessages(
            userId: PukiCore.user.currentUser!.id,
            room: chat.value!.room!,
            messages: List.from(chat.value!.messages),
          );
        });
      }
    }, onError: (error) {
      print('Error in messages stream: $error');
    });
  }

  void _initializeUsersListener() {
    _usersSubscription = PukiCore.firestore.user.streamAllUsers(userIds: chat.value!.room!.users).listen((users) {
      if (chat.value != null) {
        chat.value = PmChat(
          room: chat.value!.room,
          messages: chat.value!.messages,
          members: users,
          formerMembers: chat.value!.formerMembers,
        );
      }
    }, onError: (error) {
      print('Error in user stream: $error');
    });
  }

  void reset() {
    chat.value = null;
    isLoading.value = false;
    _roomSubscription?.cancel();
    _messagesSubscription?.cancel();
    _usersSubscription?.cancel();
  }
}
