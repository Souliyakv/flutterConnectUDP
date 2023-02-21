import 'dart:convert';
import 'dart:io';

import 'package:demoudp/model/typingStatusModel.dart';
import 'package:demoudp/providers/statusTypingProvider.dart';
import 'package:demoudp/providers/textMessage_provider.dart';
import 'package:demoudp/services/enoumDataService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/connectSocketUDP_model.dart';
import '../model/textMessage_model.dart';
import '../widget/config.dart';

class ConnectSocketUDPProvider with ChangeNotifier {
  late RawDatagramSocket socket;
  String data = '';
  void login(LoginModel loginDataMD, BuildContext context) {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 2222)
        .then((RawDatagramSocket socket) {
      this.socket = socket;
      this.socket.listen((event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = this.socket.receive();
          List<int> result = dg!.data;
          data = utf8.decode(result);

          switch (json.decode(data)['command']) {
            case "txtsend":
              txtsend(context);
              break;

            case "typingStatus":
              GetTypingStatusModel getTypingStatusModel = GetTypingStatusModel(
                  status: json.decode(data)['status'],
                  channel: json.decode(data)['channel']);
              var pvdStatustyng =
                  Provider.of<StatusTypingProvider>(context, listen: false);
              pvdStatustyng.addStatusTyping(getTypingStatusModel);
              break;
            default:
              print('NO');
              break;
          }
        }
      });
      var loginData = {
        "data": {
          "userName": loginDataMD.username,
          "password": loginDataMD.password
        },
        "command": Ecommand().login,
      };
      this.socket.send(utf8.encode(jsonEncode(loginData)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
    });
  }

  void txtsend(BuildContext context) {
    TextMessageModel textMessageModel = TextMessageModel(
        message: json.decode(data)['message'],
        sender: json.decode(data)['sender'],
        hour: json.decode(data)['hour'],
        minute: json.decode(data)['minute'],
        channel: json.decode(data)['channel'],
        type: json.decode(data)['type']);
    var provider = Provider.of<TextMessageProvider>(context, listen: false);
    provider.addTextMessage(textMessageModel);
  }

  void sendtxtMessage(SendTextMessageModel sendtxtData) {
    var txtdataToSend = {
      "data": {
        "message": sendtxtData.message,
        "channel": sendtxtData.channel,
        "type": "TEXT",
        "sender": sendtxtData.sender,
        "hour": sendtxtData.hour,
        "minute": sendtxtData.minute
      },
      "token": sendtxtData.token,
      "command": Ecommand().txtsend
    };
    this.socket.send(utf8.encode(jsonEncode(txtdataToSend)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }

  void sendstatusTyping(SendTypingStatusModel statusModel) {
    var sendStatus = {
      "data": {
        "status": statusModel.status,
        "channel": statusModel.channel,
      },
      "token": statusModel.token,
      "command": Ecommand().typingStatus
    };
    this.socket.send(utf8.encode(jsonEncode(sendStatus)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }
}
