import 'dart:convert';
import 'dart:io';

import 'package:demoudp/model/getImageModel.dart';
import 'package:demoudp/model/imageModel.dart';
import 'package:demoudp/model/typingStatusModel.dart';
import 'package:demoudp/providers/getImageProvider.dart';
import 'package:demoudp/providers/imageProvider.dart';
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
    var pvdGetImage = Provider.of<GetImageProvider>(context, listen: false);
    var provider = Provider.of<TextMessageProvider>(context, listen: false);
    var pvdImage = Provider.of<ChooseImageProvider>(context, listen: false);
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 2222)
        .then((RawDatagramSocket socket) {
      this.socket = socket;
      this.socket.listen((event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = this.socket.receive();
          List<int> result = dg!.data;
          data = utf8.decode(result);
          // print(json.decode(data)['command']);

          switch (json.decode(data)['command']) {
            case "txtsend":
              TextMessageModel textMessageModel = TextMessageModel(
                  message: json.decode(data)['message'],
                  sender: json.decode(data)['sender'],
                  hour: json.decode(data)['hour'],
                  minute: json.decode(data)['minute'],
                  channel: json.decode(data)['channel'],
                  type: json.decode(data)['type']);
              provider.addTextMessage(textMessageModel);
              break;

            case "typingStatus":
              GetTypingStatusModel getTypingStatusModel = GetTypingStatusModel(
                  status: json.decode(data)['status'],
                  channel: json.decode(data)['channel']);
              var pvdStatustyng =
                  Provider.of<StatusTypingProvider>(context, listen: false);
              pvdStatustyng.addStatusTyping(getTypingStatusModel);
              break;
            case "sendTotal":
              GetTotalModel getTotalModel = GetTotalModel(
                trans: json.decode(data)['trans'],
                total: json.decode(data)['total'],
                address: json.decode(data)['address'],
                port: json.decode(data)['port'],
              );
              DetailImageModel detailImageModel = DetailImageModel(
                  trans: json.decode(data)['trans'].toString(),
                  sender: json.decode(data)['sender'].toString(),
                  channel: json.decode(data)['channel'].toString());
              pvdGetImage.addDetailImage(detailImageModel);
              pvdGetImage.sendTotal(getTotalModel, context);
              break;
            case "confirmToSend":
              ConfirmToSendModel sendModel = ConfirmToSendModel(
                  start: json.decode(data)['start'],
                  end: json.decode(data)['end'],
                  address: json.decode(data)['address'],
                  port: json.decode(data)['port'],
                  trans: json.decode(data)['trans']);
              pvdImage.addsendIndex(json.decode(data)['trans']);
              SendMessageIMGModel result = pvdImage.sendMessage(sendModel);
              sendMessage(result);

              break;
            case "ack":
              ConfirmToSendModel sendModel = ConfirmToSendModel(
                  start: json.decode(data)['start'],
                  end: json.decode(data)['end'],
                  address: json.decode(data)['address'],
                  port: json.decode(data)['port'],
                  trans: json.decode(data)['trans']);
              SendMessageIMGModel result = pvdImage.sendMessage(sendModel);
              if (result.sumData != 0) {
                sendMessage(result);
              }
              break;
            case "refund":
              RefunDataModel refunDataModel = RefunDataModel(
                  message: json.decode(data)['message'],
                  total: json.decode(data)['total'],
                  round: json.decode(data)['round'],
                  sumData: json.decode(data)['sumData'],
                  address: json.decode(data)['address'],
                  port: json.decode(data)['port'],
                  trans: json.decode(data)['trans'],
                  type: json.decode(data)['type']);
              pvdImage.sendRefunData(refunDataModel, context);
              break;
            case "ackResend":
              RefunDataModel refunDataModel = RefunDataModel(
                  message: [],
                  total: 0,
                  round: 0,
                  sumData: 0,
                  address: json.decode(data)['address'],
                  port: json.decode(data)['port'],
                  trans: json.decode(data)['trans'],
                  type: json.decode(data)['type']);
              pvdImage.resend(refunDataModel, context);
              break;
            case "resend":
              GetResendDataModel getResendDataModel = GetResendDataModel(
                  address: json.decode(data)['address'],
                  index: json.decode(data)['index'],
                  message: json.decode(data)['message'],
                  port: json.decode(data)['port'],
                  round: json.decode(data)['round'],
                  sumData: json.decode(data)['sumData'],
                  total: json.decode(data)['total'],
                  trans: json.decode(data)['trans'],
                  type: json.decode(data)['type']);
              pvdGetImage.resendData(getResendDataModel, context);
              break;
            case "success":
              pvdImage.success(json.decode(data)['trans']);
              break;
            default:
              PushBufferToImageModel pushBufferToImageModel =
                  PushBufferToImageModel(
                      message: json.decode(data)['message'],
                      index: json.decode(data)['index'],
                      total: json.decode(data)['total'],
                      round: json.decode(data)['round'],
                      sumData: json.decode(data)['sumData'],
                      address: json.decode(data)['address'],
                      end: json.decode(data)['end'],
                      port: json.decode(data)['port'],
                      start: json.decode(data)['start'],
                      trans: json.decode(data)['trans']);
              pvdGetImage.pushBufferToImage(pushBufferToImageModel, context);
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

  void sendImage(SendImageModel sendImageModel, BuildContext context) {
    var pvdImage = Provider.of<ChooseImageProvider>(context, listen: false);
    var allImageToSend = pvdImage.allImageToSend;
    var allImageToSendKey = pvdImage.allImageToSendKey;

    for (var i = 0; i < allImageToSendKey.length; i++) {
      var sendImageData = {
        'data': {
          'total': allImageToSend[allImageToSendKey[i]].length,
          'channel': sendImageModel.channel,
          'trans': allImageToSendKey[i]
        },
        'token': sendImageModel.token,
        'command': Ecommand().sendTotal
      };
      // print(sendImageModel.channel);
      socket.send(utf8.encode(jsonEncode(sendImageData)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
    }
    // print(sendImageData);
  }

  void confirmToSend(ConfirmToSendModel confirmToSendModel) {
    var dataConfirm = {
      'data': {
        "start": confirmToSendModel.start,
        "end": confirmToSendModel.end,
        "address": confirmToSendModel.address,
        "port": confirmToSendModel.port,
        "trans": confirmToSendModel.trans
      },
      "command": Ecommand().confirmToSend
    };
    socket.send(utf8.encode(jsonEncode(dataConfirm)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }

  void sendMessage(SendMessageIMGModel sendMessageIMGModel) {
    var dataToSend = {
      "data": {
        "message": sendMessageIMGModel.message,
        "type": "IMAGE",
        "index": sendMessageIMGModel.index,
        "total": sendMessageIMGModel.total,
        "round": sendMessageIMGModel.round,
        "start": sendMessageIMGModel.start,
        "end": sendMessageIMGModel.end,
        "sumData": sendMessageIMGModel.sumData,
        "address": sendMessageIMGModel.address,
        "port": sendMessageIMGModel.port,
        "trans": sendMessageIMGModel.trans,
      },
      "command": "send"
    };
    // print(sendMessageIMGModel.end);
    // print(sendMessageIMGModel.index);
    // print(sendMessageIMGModel.sumData);
    socket.send(utf8.encode(jsonEncode(dataToSend)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }

  void refundData(RefunDataModel refunDataModel) {
    var dataRefund = {
      "data": {
        "message": refunDataModel.message,
        "type": refunDataModel.type,
        "total": refunDataModel.total,
        "round": refunDataModel.round,
        "sumData": refunDataModel.sumData,
        "address": refunDataModel.address,
        "port": refunDataModel.port,
        "trans": refunDataModel.trans,
      },
      "command": Ecommand().refund
    };
    this.socket.send(utf8.encode(jsonEncode(dataRefund)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }

  sendSuccess(SendSuccessModel sendSuccessModel) {
    var dataSuccess = {
      'data': {
        'trans': sendSuccessModel.trans,
        'address': sendSuccessModel.address,
        'port': sendSuccessModel.port,
      },
      'command': Ecommand().success
    };
    socket.send(utf8.encode(jsonEncode(dataSuccess)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }

  resend(ResendDataModel resendDataModel) {
    var resendData = {
      "data": {
        "message": resendDataModel.message,
        "type": resendDataModel.type,
        "total": resendDataModel.total,
        "round": resendDataModel.round,
        "index": resendDataModel.index,
        "sumData": resendDataModel.sumData,
        "address": resendDataModel.address,
        "port": resendDataModel.port,
        'trans': resendDataModel.trans
      },
      "command": Ecommand().resend
    };
    this.socket.send(utf8.encode(jsonEncode(resendData)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }
}
