import 'package:get/get.dart';
import 'package:puki/puki.dart';
import 'package:wee_kit/wee_kit.dart';

class MessageController extends GetxController {
  List<PmGroupingMessages> groupMessageByDate(List<PmMessage> messages) {
    Map<String, List<PmMessage>> groupedMessages = {};

    for (var message in messages) {
      String formattedDate = WeeDateTime.dateToString(message.date.toDate(), "dd MMMM, yyyy");

      if (!groupedMessages.containsKey(formattedDate)) {
        groupedMessages[formattedDate] = [];
      }
      groupedMessages[formattedDate]!.add(message); // Tambahkan pesan ke grup
    }

    List<PmGroupingMessages> groupedMessageList = groupedMessages.entries.map((e) => PmGroupingMessages(date: e.key, messages: e.value)).toList();

    return groupedMessageList;
  }
}
