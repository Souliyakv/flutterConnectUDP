import 'package:demoudp/model/textMessage_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

class TextMessageProvider with ChangeNotifier {
  // List<TextMessageModel> lTextMessages = [
  //   // TextMessageModel(
  //   //     message:
  //   //         "https://img.freepik.com/free-photo/wide-angle-shot-single-tree-growing-clouded-sky-during-sunset-surrounded-by-grass_181624-22807.jpg",
  //   //     sender: "a",
  //   //     hour: "15",
  //   //     minute: "45",
  //   //     channel: "1",
  //   //     type: 'IMAGE'),
  //   // TextMessageModel(
  //   //     message:
  //   //         "https://natureconservancy-h.assetsadobe.com/is/image/content/dam/tnc/nature/en/photos/Zugpsitze_mountain.jpg?crop=0%2C176%2C3008%2C1654&wid=4000&hei=2200&scl=0.752",
  //   //     sender: "b",
  //   //     hour: "15",
  //   //     minute: "45",
  //   //     channel: "1",
  //   //     type: 'IMAGE'),
  // ];
  var lTextMessages = {};
  String channelNoti = 'no channel';
  String usernameNoti = 'no user';

  // List<TextMessageModel> getTextMessage() {
  //   return lTextMessages;
  // }

  getMessage(String channel, username) {
    channelNoti = channel;
    usernameNoti = username;
    return lTextMessages[channel];
  }

  Future<void> _showNotification(String sender, message, Type) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('nextflow_noti_001', 'ແຈ້ງເຕືອນທົ່ວໄປ',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(badgeNumber: 2);

    const NotificationDetails platformChannelDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    if (Type == 'TEXT') {
      flutterLocalNotificationsPlugin.show(
          0, '${sender}', '${message}', platformChannelDetails);
    } else if (Type == 'IMAGE') {
      flutterLocalNotificationsPlugin.show(
          0, '${sender}', 'ໄດ້ສົ່ງ: ຮູບພາບ', platformChannelDetails);
    } else if (Type == 'VIDEO') {
      flutterLocalNotificationsPlugin.show(
          0, '${sender}', 'ໄດ້ສົ່ງ: ວິດີໂອ', platformChannelDetails);
    } else if (Type == 'AUDIO') {
      flutterLocalNotificationsPlugin.show(
          0, '${sender}', 'ໄດ້ສົ່ງ: ສຽງ', platformChannelDetails);
    }
  }

  void addTextMessage(TextMessageModel messageData) {
    // lTextMessages.insert(0, messageData);
    if (lTextMessages[messageData.channel] == null) {
      lTextMessages.addAll({messageData.channel.toString(): []});
    }
    lTextMessages[messageData.channel.toString()].insert(0, messageData);
    if (messageData.channel != channelNoti &&
        messageData.sender != usernameNoti) {
      _showNotification(
          messageData.sender, messageData.message, messageData.type);
    }

    notifyListeners();
  }
}
