import 'package:demoudp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotoficationScreen extends StatefulWidget {
  const NotoficationScreen({super.key});

  @override
  State<NotoficationScreen> createState() => _NotoficationScreenState();
}

class _NotoficationScreenState extends State<NotoficationScreen> {
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('nextflow_noti_001', 'ແຈ້ງເຕືອນທົ່ວໄປ',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(badgeNumber: 2);

    const NotificationDetails platformChannelDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    flutterLocalNotificationsPlugin.show(
        0, 'a', 'to day is', platformChannelDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification")),
      body: Center(
        child: TextButton(
          onPressed: () {
            _showNotification();
          },
          child: Text("Noti"),
        ),
      ),
    );
  }
}
