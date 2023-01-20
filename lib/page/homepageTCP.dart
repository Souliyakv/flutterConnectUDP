import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';

class HomeScreenTCP extends StatefulWidget {
  const HomeScreenTCP({super.key});

  @override
  State<HomeScreenTCP> createState() => _HomeScreenTCPState();
}

class _HomeScreenTCPState extends State<HomeScreenTCP> {
  String message = "";
  TcpSocketConnection socketConnection =
      TcpSocketConnection('192.168.0.131', 8080);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startConnection();
  }

  void startConnection() async {
    socketConnection.enableConsolePrint(true);

    if (await socketConnection.canConnect(5000, attempts: 3)) {
      await socketConnection.connect(5000, messageReceived, attempts: 3);
    }
    socketConnection.sendMessage(jsonEncode({"msg": "MessageIsReceived :D "}));
  }

  void messageReceived(String msg) async {
    print('msg' + msg);
    setState(() {
      message = msg;
    });
    // socketConnection.sendMessage("MessageIsReceived :D ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('data')),
      body: Center(child: Text("Print data" + message)),
    );
  }
}
