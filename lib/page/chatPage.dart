import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:demoudp/model/imageModel.dart';
import 'package:demoudp/model/textMessage_model.dart';
import 'package:demoudp/model/typingStatusModel.dart';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:demoudp/providers/imageProvider.dart';
import 'package:demoudp/providers/statusTypingProvider.dart';
import 'package:demoudp/providers/textMessage_provider.dart';
import 'package:demoudp/widget/config.dart';
import 'package:demoudp/widget/showAlert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String username;
  final String password;
  final String channel;
  const ChatPage(
      {super.key,
      required this.username,
      required this.password,
      required this.channel});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode.addListener(_onFocusChange);
    setState(() {
      _username = widget.username;
      _password = widget.password;
      _to = widget.channel;
    });
    // login();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  FocusNode _focusNode = FocusNode();

  void _onFocusChange() {
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    if (_focusNode.hasFocus) {
      SendTypingStatusModel sendstatus =
          SendTypingStatusModel(status: true, channel: _to, token: _username);
      pvdConnect.sendstatusTyping(sendstatus);
      setState(() {
        sendImage = false;
      });
    } else {
      SendTypingStatusModel sendstatus =
          SendTypingStatusModel(status: false, channel: _to, token: _username);
      pvdConnect.sendstatusTyping(sendstatus);
      setState(() {
        sendImage = true;
      });
    }
  }

  late Uint8List imagebytes = new Uint8List(0);
  var imageFireResult;
  File? file;
  String data = '';
  late String message;
  var dataArr = {};
  var dataArrCheck = {};
  bool sendImage = false;
  var missingIndex = {};
  final txtMessage = TextEditingController();
  late String _username;
  late String _password;
  late String _to;
  int showImage = 0;
  int totalSendAgain = 0;
  double percent = 0;
  var sendIndex = {};

  var resendIndex = {};
  late Timer timeOut;
  late Timer timeOutSend;
  late Timer timeOutResend;
  var checkTimeout = {};
  List<int> checkTimeoutIndex = [];

  var dataListRefund = {};

  int totalBuffer = 0;
  int totalBufferTo = 0;
  var total = {};
  var totalToCheck = {};
  int roundTosend = 100;
  int totalImageTosend = 0;
  var _start = {};

  var _end = {};
  int percenNumber = 0;
  var allImageToSend = {};
  List<int> allImageToSendKey = [];

  late Uint8List _bytes;
  late RawDatagramSocket socket;
  var allImageToShow = [];
  void login() async {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 2222)
        .then((RawDatagramSocket socket) {
      this.socket = socket;
      this.socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = this.socket.receive();
          List<int> result = dg!.data;
          setState(() {
            data = utf8.decode(result);
          });

          if (json.decode(data)['command'] == "ack") {
            sendMessage(data);
          } else if (json.decode(data)['command'] == 'refund') {
            _sendRefunData(data);
          } else if (json.decode(data)['command'] == 'resend') {
            _resendData(data);
          } else if (json.decode(data)['command'] == 'ackResend') {
            resend(data);
          } else if (json.decode(data)['command'] == 'sendTotal') {
            _sendTotal(data);
          } else if (json.decode(data)['command'] == 'confirmToSend') {
            sendIndex.addAll({json.decode(data)['trans']: 0});
            sendMessage(data);
          } else if (json.decode(data)['command'] == 'success') {
            allImageToSend.remove(json.decode(data)['trans']);
            allImageToSendKey.remove(json.decode(data)['trans']);
            setState(() {
              totalImageTosend = allImageToSendKey.length;
            });
          } else if (json.decode(data)['command'] == 'NoUser') {
            ShowAlert.showAlert(context,
                'ບໍ່ມີຊື່ຜູ້ໃຊ້ ${json.decode(data)['username']} ຢູ່ໃນລະບົບ');
          } else if (json.decode(data)['command'] == 'txtsend') {
            // TextMessageModel textMessageModel = TextMessageModel(
            //     message: json.decode(data)['message'],
            //     sender: json.decode(data)['sender'],
            //     hour: json.decode(data)['hour'],
            //     minute: json.decode(data)['minute'],
            //     channel: json.decode(data)['channel'],
            //     type: json.decode(data)['type']);
            // var provider =
            //     Provider.of<TextMessageProvider>(context, listen: false);
            // provider.addTextMessage(textMessageModel);
          } else if (json.decode(data)['command'] == 'typingStatus') {
            // setState(() {
            //   typing = json.decode(data)['status'];
            // });
          } else {
            _pushButterToImage(data);
          }
        }
      });
      var login = {
        "data": {"userName": _username, "password": _password},
        "command": "login",
      };
      this.socket.send(utf8.encode(jsonEncode(login)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
    });
  }

  void send(var index) {
    var dataSend = {
      'data': {
        'total': allImageToSend[index].length,
        'channel': _to,
        'trans': index,
      },
      "token": _username,
      "command": 'sendTotal'
    };
    print(dataSend);
    socket.send(utf8.encode(jsonEncode(dataSend)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }

  // void sendstatusTyping(bool status) {
  //   var sendStatus = {
  //     "data": {
  //       "status": status,
  //       "channel": _to,
  //     },
  //     "token": _username,
  //     "command": "typingStatus"
  //   };
  //   print(sendStatus);
  //   this.socket.send(utf8.encode(jsonEncode(sendStatus)),
  //       InternetAddress("${IpAddress().ipAddress}"), 2222);
  // }

  void _sendTotal(var dataSendTotal) {
    _start.addAll({json.decode(dataSendTotal)['trans']: 0});
    _end.addAll({json.decode(dataSendTotal)['trans']: roundTosend});
    missingIndex.addAll({json.decode(dataSendTotal)['trans']: []});
    checkTimeoutIndex.remove(json.decode(dataSendTotal)['trans']);
    checkTimeoutIndex.add(json.decode(dataSendTotal)['trans']);

    setState(() {
      showImage == 0;
    });

    dataArrCheck.addAll({json.decode(dataSendTotal)['trans']: []});
    total.addAll({
      json.decode(dataSendTotal)['trans']: json.decode(dataSendTotal)['total']
    });

    totalToCheck.addAll({
      json.decode(dataSendTotal)['trans']: json.decode(dataSendTotal)['total']
    });
    _genData(dataSendTotal);
    if (total[json.decode(dataSendTotal)['trans']] <=
        _end[json.decode(dataSendTotal)['trans']]) {
      _end.update(json.decode(dataSendTotal)['trans'],
          (value) => total[json.decode(dataSendTotal)['trans']]);
    }

    _confirmToSend(dataSendTotal);
  }

  void _confirmToSend(var dataConfirmToSend) {
    if (_start[json.decode(dataConfirmToSend)['trans']] >=
        total[json.decode(dataConfirmToSend)['trans']]) {
    } else {
      _addDataToCheck(
          _start[json.decode(dataConfirmToSend)['trans']],
          _end[json.decode(dataConfirmToSend)['trans']],
          json.decode(dataConfirmToSend)['trans']);

      checkTimeout
          .addAll({json.decode(dataConfirmToSend)['trans']: dataConfirmToSend});
      waitTimeOutToCheck();
      var dataConfirm = {
        'data': {
          "start": _start[json.decode(dataConfirmToSend)['trans']],
          "end": _end[json.decode(dataConfirmToSend)['trans']],
          "address": json.decode(dataConfirmToSend)['address'],
          "port": json.decode(dataConfirmToSend)['port'],
          "trans": json.decode(dataConfirmToSend)['trans']
        },
        "command": 'confirmToSend'
      };

      socket.send(utf8.encode(jsonEncode(dataConfirm)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);

      int checkEnd =
          _end[json.decode(dataConfirmToSend)['trans']] + roundTosend;

      if (checkEnd >= total[json.decode(dataConfirmToSend)['trans']]) {
        _start.update(
            json.decode(dataConfirmToSend)['trans'],
            (value) =>
                int.parse(_start[json.decode(dataConfirmToSend)['trans']]
                    .toString()) +
                roundTosend);
        _end.update(json.decode(dataConfirmToSend)['trans'],
            (value) => total[json.decode(dataConfirmToSend)['trans']]);
      } else {
        _start.update(
            json.decode(dataConfirmToSend)['trans'],
            (value) =>
                int.parse(_start[json.decode(dataConfirmToSend)['trans']]
                    .toString()) +
                roundTosend);
        _end.update(
            json.decode(dataConfirmToSend)['trans'],
            (value) =>
                int.parse(
                    _end[json.decode(dataConfirmToSend)['trans']].toString()) +
                roundTosend);
        // setState(() {
        //   // _start = _start + roundTosend;
        //   _end = _end + roundTosend;
        // });
      }
    }
    // print('confirm to send');
  }

  void sendMessage(var dataSend) {
    int sendIndexData = json.decode(dataSend)['start'] +
        sendIndex[json.decode(dataSend)['trans']];
    // print(sendIndexData);

    int total = json.decode(dataSend)['end'] - json.decode(dataSend)['start'];
    // print(data);
    if (sendIndexData < json.decode(dataSend)['end']) {
      var dataToSend = {
        "data": {
          "message": allImageToSend[json.decode(dataSend)['trans']]
              [sendIndexData],
          "channel": _to,
          "type": "IMAGE",
          "index": sendIndexData,
          "total": total,
          "round": sendIndex[json.decode(dataSend)['trans']] + 1,
          "start": json.decode(dataSend)['start'],
          "end": json.decode(dataSend)['end'],
          "sumData": allImageToSend[json.decode(dataSend)['trans']]
                  [sendIndexData]
              .length,
          "address": json.decode(dataSend)['address'],
          "port": json.decode(dataSend)['port'],
          "trans": json.decode(dataSend)['trans'],
        },
        "command": "send"
      };
      // waitTimeOutToSendAgain(dataToSend);
      this.socket.send(utf8.encode(jsonEncode(dataToSend)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
      sendIndex.update(
          json.decode(dataSend)['trans'],
          (value) =>
              int.parse(sendIndex[json.decode(dataSend)['trans']].toString()) +
              1);
    }
  }

  // void sendtxtMessage(String message, sender, hour, minute) {
  //   var txtdataToSend = {
  //     "data": {
  //       "message": message,
  //       "channel": _to,
  //       "type": "TEXT",
  //       "sender": sender,
  //       "hour": hour,
  //       "minute": minute
  //     },
  //     "token": _username,
  //     "command": "txtsend"
  //   };
  //   this.socket.send(utf8.encode(jsonEncode(txtdataToSend)),
  //       InternetAddress("${IpAddress().ipAddress}"), 2222);
  // }

  void sendAg(var sendAgain) {
    timeOutSend.cancel();
    if (totalSendAgain >= 3) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("ການສົ່ງລົ້ມເຫຼວ ກະລຸຮາກວດສອບອິນເຕີແນັດ"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("ຕົກລົງ"))
            ],
          );
        },
      );
    } else {
      var dataToSend = {
        "data": {
          "message": json.decode(sendAgain)['data']['message'],
          "channel": json.decode(sendAgain)['data']['channel'],
          "type": json.decode(sendAgain)['data']['type'],
          "index": json.decode(sendAgain)['data']['index'],
          "total": json.decode(sendAgain)['data']['total'],
          "round": json.decode(sendAgain)['data']['round'],
          "start": json.decode(sendAgain)['data']['start'],
          "end": json.decode(sendAgain)['data']['end'],
          "sumData": json.decode(sendAgain)['data']['sumData'],
          "address": json.decode(sendAgain)['data']['address'],
          "port": json.decode(sendAgain)['data']['port'],
          "trans": json.decode(sendAgain)['data']['trans'],
        },
        "command": "send"
      };
      // waitTimeOutToSendAgain(dataToSend);
      this.socket.send(utf8.encode(jsonEncode(dataToSend)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
      setState(() {
        totalSendAgain++;
      });
    }
  }

  void resendAg(var resendAg) {
    var resend = {
      "data": {
        "message": json.decode(resendAg)['data']['message'],
        "channel": json.decode(resendAg)['data']['channel'],
        "type": json.decode(resendAg)['data']['type'],
        "total": json.decode(resendAg)['data']['total'],
        "round": json.decode(resendAg)['data']['round'],
        "index": json.decode(resendAg)['data']['index'],
        "sumData": json.decode(resendAg)['data']['sumData'],
        "address": json.decode(resendAg)['data']['address'],
        "port": json.decode(resendAg)['data']['port'],
        'trans': json.decode(resendAg)['data']['trans']
      },
      "token": json.decode(resendAg)['token'],
      "command": "resend"
    };
    this.socket.send(utf8.encode(jsonEncode(resend)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }

  void resend(var dataResend) {
    if (resendIndex[json.decode(dataResend)['trans']] !=
        dataListRefund[json.decode(dataResend)['trans']].length) {
      int dataIndex = dataListRefund[json.decode(dataResend)['trans']]
          [resendIndex[json.decode(dataResend)['trans']]];
      var resend = {
        "data": {
          "message": allImageToSend[json.decode(dataResend)['trans']]
              [dataIndex],
          "channel": _to,
          "type": "IMAGE",
          "total": dataListRefund[json.decode(dataResend)['trans']].length,
          "round": resendIndex[json.decode(dataResend)['trans']] + 1,
          "index": dataListRefund[json.decode(dataResend)['trans']]
              [resendIndex[json.decode(dataResend)['trans']]],
          "sumData": allImageToSend[json.decode(dataResend)['trans']][dataIndex]
              .length,
          "address": json.decode(dataResend)['address'],
          "port": json.decode(dataResend)['port'],
          'trans': json.decode(dataResend)['trans']
        },
        "token": _username,
        "command": "resend"
      };
      this.socket.send(utf8.encode(jsonEncode(resend)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
      resendIndex.update(
          json.decode(dataResend)['trans'],
          (value) =>
              int.parse(
                  resendIndex[json.decode(dataResend)['trans']].toString()) +
              1);
    } else {
      print('resendSuccess');
    }
  }

  void _sendRefunData(String dataRefund) {
    resendIndex.addAll({json.decode(dataRefund)['trans']: 0});
    dataListRefund.addAll(
        {json.decode(dataRefund)['trans']: json.decode(dataRefund)['message']});
    resend(dataRefund);
  }

  void _resendData(String dataResend) {
    int indexAdd = json.decode(dataResend)['index'];
    if (dataArr[json.decode(dataResend)['trans']] != null) {
      if (json.decode(dataResend)['message'].length ==
          json.decode(dataResend)['sumData']) {
        var resultRemove = _removeDataToCheck(dataResend);
        if (resultRemove == true) {
          _removeAndAdds(dataResend);
          dataArrCheck[json.decode(dataResend)['trans']]
              .add(json.decode(dataResend)['index']);
        }

        if (json.decode(dataResend)['round'] ==
            json.decode(dataResend)['total']) {
          _convertToImage(dataResend);
        } else {
          print('checkTime');
        }
      } else {
        print("NO");
      }
    }
  }

  Future chooseImage(BuildContext context) async {
    try {
      var image = await ImagePicker().getImage(source: ImageSource.gallery);
      file = File(image!.path);
      imagebytes = await file!.readAsBytes();
      // print(imagebytes.length);
      var keyIndex;
      setState(() {
        totalBuffer = imagebytes.length;
        keyIndex = DateTime.now().millisecondsSinceEpoch;
      });
      // allImageToSendKey.add(keyIndex);

      totalImageTosend = allImageToSendKey.length;
      int chunkSize = 2000;

      List<Uint8List> sperate = [];
      // sperate.clear();
      for (int i = 0; i < imagebytes.length; i += chunkSize) {
        int end = i + chunkSize < imagebytes.length
            ? i + chunkSize
            : imagebytes.length;
        sperate.add(imagebytes.sublist(i, end));
      }
      // allImageToSend.addAll({keyIndex: sperate});
      ChooseImageModel chooseImageModel =
          ChooseImageModel(keyIndex: keyIndex, sperate: sperate);

      var pvdChooseImage =
          Provider.of<ChooseImageProvider>(context, listen: false);
      pvdChooseImage.addImageToSend(chooseImageModel);
    } catch (e) {
      print(e);
    }
  }

  void sendSuccess(var dataSuc) {
    var dataSuccess = {
      'data': {
        'trans': json.decode(dataSuc)['trans'],
        'address': json.decode(dataSuc)['address'],
        'port': json.decode(dataSuc)['port'],
      },
      'command': 'success'
    };
    this.socket.send(utf8.encode(jsonEncode(dataSuccess)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
    print('send success');
  }

  void _convertToImage(var dataConvert) {
    timeOut.cancel();

    List<dynamic> newList = [];
    newList.clear();

    if (missingIndex[json.decode(dataConvert)['trans']] == null ||
        missingIndex[json.decode(dataConvert)['trans']].length == 0) {
      if (dataArrCheck[json.decode(dataConvert)['trans']].length ==
          totalToCheck[json.decode(dataConvert)['trans']]) {
        for (int i = 0;
            i < dataArr[json.decode(dataConvert)['trans']].length;
            i++) {
          newList.addAll(jsonDecode(
              dataArr[json.decode(dataConvert)['trans']][i].toString()));
        }

        sendSuccess(dataConvert);
        missingIndex.remove(json.decode(dataConvert)['trans']);
        dataArr.remove(json.decode(dataConvert)['trans']);
        dataArrCheck.remove(json.decode(dataConvert)['trans']);
        checkTimeoutIndex.remove(json.decode(dataConvert)['trans']);
        checkTimeout.remove(json.decode(dataConvert)['trans']);
        waitTimeOutToCheck();
        setState(() {
          String base64string = base64.encode(newList.cast<int>());
          imageFireResult = "data:image/jpg;base64,$base64string";
          String uri = imageFireResult.toString();
          _bytes = base64.decode(uri.split(',').last);
          allImageToShow.add(_bytes);

          showImage = 1;
          totalBufferTo = newList.length;
          // saveToStorage(base64string);
        });

        newList.clear();
      } else {
        _confirmToSend(dataConvert);
      }
    } else {
      _refundData(dataConvert);
    }
  }

  void saveToStorage(var dataToSave) async {
    Uint8List bytes = base64.decode(dataToSave);
    // print(bytes);
    final dir = await getExternalStorageDirectory();
    File file = File("${dir!.path}/" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".jpg");
    await file.writeAsBytes(bytes);
    print(file.path);
  }

  void _pushButterToImage(String dataBuffer) {
    if (dataArr[json.decode(dataBuffer)['trans']] != null) {
      if (json.decode(dataBuffer)['message'].length ==
          json.decode(dataBuffer)['sumData']) {
        var result = _removeDataToCheck(dataBuffer);
        if (result == true) {
          _removeAndAdds(dataBuffer);
          dataArrCheck[json.decode(dataBuffer)['trans']]
              .add(json.decode(dataBuffer)['index']);
        }

        if (json.decode(dataBuffer)['total'] ==
            json.decode(dataBuffer)['round']) {
          _convertToImage(dataBuffer);
        }
      }
      setState(() {
        double index =
            double.parse(json.decode(dataBuffer)['index'].toString());
        percent = index / totalToCheck[json.decode(dataBuffer)['trans']];
        double cal = index * 100;
        percenNumber = cal ~/ totalToCheck[json.decode(dataBuffer)['trans']];
      });
    }
  }

  Future<void> waitTimeOutToCheck() async {
    timeOut = Timer(Duration(seconds: 2), () {
      for (var i = 0; i < checkTimeoutIndex.length; i++) {
        if (dataArr[json.decode(checkTimeout[checkTimeoutIndex[i]])['trans']] !=
            null) {
          _convertToImage(checkTimeout[checkTimeoutIndex[i]]);
        } else {
          timeOut.cancel();
        }
      }
    });
  }

  Future<void> waitTimeOutToSendAgain(var dataSend) async {
    timeOutSend = Timer(Duration(seconds: 5), () {
      // print('PrinttimeOut');
      // _convertToImage(dataWait);
      sendAg(dataSend);
    });

    // and later, before the timer goes off...
    // t.cancel();
  }

  Future<void> waitTimeOutToResendAgain(var dataResendAg) async {
    timeOutResend = Timer(Duration(seconds: 5), () {
      resendAg(dataResendAg);
    });
  }

  void _addDataToCheck(int start, end, var trans) {
    // print(missingIndex[trans]);
    // print("Start is :${start} End is :${end} Trans is :${trans}");

    for (var i = start; i < end; i++) {
      missingIndex[trans].add(i);
      // print('Index is :${i}');
      // print('add data trans ${trans.toString()} index : ${i.toString()}');
    }
    // print(missingIndex[trans]);
  }

  void _genData(var dataGen) {
    dataArr.addAll({json.decode(dataGen)['trans']: []});
    for (var i = 0; i < totalToCheck[json.decode(dataGen)['trans']]; i++) {
      dataArr[json.decode(dataGen)['trans']].add(i.toString());
      // print(
      //     'gen data trans :${json.decode(dataGen)['trans']} number :${totalToCheck[json.decode(dataGen)['trans']]}');
    }

    // print('all data is :'+dataArr.toString());
  }

  _removeAndAdds(var removeAndAdd) {
    var result = dataArr[json.decode(removeAndAdd)['trans']]
        .remove(json.decode(removeAndAdd)['index'].toString());
    //  print('number remove is :' + index.toString());
    // print('result remove is :' + result.toString());
    // print(dataArr[trans]);
    // print(
    //     'remove data trans :${json.decode(removeAndAdd)['trans']} is :${result}');
    if (result == true) {
      dataArr[json.decode(removeAndAdd)['trans']].insert(
          json.decode(removeAndAdd)['index'],
          json.decode(removeAndAdd)['message'].toString());
    }
  }

  _removeDataToCheck(var removeAndCheck) {
    // print('remove data to check');
    // print(missingIndex[json.decode(removeAndCheck)['trans']]);

    // print('number remove is :' + number.toString());
    var result = missingIndex[json.decode(removeAndCheck)['trans']]
        .remove(json.decode(removeAndCheck)['index']);
    // print('trans is :' + trans.toString());
    // print('result remove is :' + result.toString());
    // print(
    //     "trans is :${json.decode(removeAndCheck)['trans']} remove :${json.decode(removeAndCheck)['index']} result is :${result}");
    return result;
  }

// 036-12-00-01876621-001
  void _refundData(var dataRef) {
    var dataRefund = {
      "data": {
        "message": missingIndex[json.decode(dataRef)['trans']],
        "channel": _to,
        "type": "IMAGE",
        "total": 1,
        "round": 1,
        "sumData": missingIndex[json.decode(dataRef)['trans']].length,
        "address": json.decode(dataRef)['address'],
        "port": json.decode(dataRef)['port'],
        "trans": json.decode(dataRef)['trans'],
      },
      "token": _username,
      "command": "refund"
    };
    this.socket.send(utf8.encode(jsonEncode(dataRefund)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
    checkTimeout.addAll({json.decode(dataRef)['trans']: dataRef});
    // print(dataRefund);
    waitTimeOutToCheck();

    // print('refund data');
  }

  void sendtxtMessage() {
    TextMessageModel textMessageModel = TextMessageModel(
        message: txtMessage.text,
        sender: _username,
        hour: DateTime.now().hour.toString(),
        minute: DateTime.now().minute.toString(),
        channel: _to,
        type: "TEXT");
    var provider = Provider.of<TextMessageProvider>(context, listen: false);
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    provider.addTextMessage(textMessageModel);
    SendTextMessageModel sendtxtData = SendTextMessageModel(
        message: txtMessage.text,
        channel: _to,
        sender: _username,
        hour: DateTime.now().hour.toString(),
        minute: DateTime.now().minute.toString(),
        token: _username);
    pvdConnect.sendtxtMessage(sendtxtData);
    txtMessage.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 129, 149, 158),
        appBar: AppBar(
          leading: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back)),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                        image: NetworkImage(
                            "https://ssl-static.libsyn.com/p/assets/5/b/f/0/5bf0dd70c2b87bb6/AoG.png"),
                        fit: BoxFit.cover)),
              ),
            ],
          ),
          backgroundColor: Color.fromARGB(255, 4, 59, 33),
          title: Row(
            children: [
              Consumer(
                builder: (context, StatusTypingProvider statusTypingProvider,
                    child) {
                  bool typing = statusTypingProvider.typingStatus[_to];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "google assistant",
                        style: TextStyle(fontSize: 18),
                      ),
                      typing == true
                          ? const Text(
                              "ກຳລັງພິມ...",
                              style: TextStyle(fontSize: 12),
                            )
                          : const Text(
                              "ອອນລາຍ",
                              style: TextStyle(fontSize: 12),
                            )
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.video_call_rounded)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
            IconButton(
                onPressed: () {
                  var result = {};
                  result.addAll({'1': {'message':'j'}});
                  result.addAll({'2': false});
                  print(result['3']);
                },
                icon: const Icon(Icons.more_vert))
          ],
        ),
        bottomSheet: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white),
          // color: Colors.white,
          child: Form(
              child: TextFormField(
            focusNode: _focusNode,
            controller: txtMessage,
            decoration: InputDecoration(
                prefixIcon: IconButton(
                    onPressed: () {
                      chooseImage(context);
                    },
                    icon: Icon(Icons.camera_alt_sharp)),
                suffixIcon: sendImage == true && txtMessage.text.length <= 0
                    ? IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.send_time_extension))
                    : IconButton(
                        onPressed: () {
                          sendtxtMessage();
                          setState(() {
                            sendImage;
                          });
                        },
                        icon: const Icon(Icons.send)),
                labelText: "Message"),
          )),
        ),
        body: Consumer(
          builder: (context, TextMessageProvider textMessagePro, child) {
            return Padding(
              padding: EdgeInsets.only(bottom: 55),
              child: ListView.builder(
                itemCount: textMessagePro.lTextMessages.length,
                reverse: true,
                itemBuilder: (context, index) {
                  TextMessageModel dataMessage =
                      textMessagePro.lTextMessages[index];
                  if (dataMessage.sender.toString() == _username.toString()) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 204, 240, 205),
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                dataMessage.type == "TEXT"
                                    ? GestureDetector(
                                        onLongPress: () {
                                          Clipboard.setData(new ClipboardData(
                                              text: dataMessage.message));
                                        },
                                        child: Text(
                                            dataMessage.message.toString()))
                                    : Container(
                                        height: 200,
                                        width: 200,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    "${dataMessage.message}"),
                                                fit: BoxFit.cover)),
                                      ),
                                Text(
                                  '${dataMessage.hour}:${dataMessage.minute} ນ',
                                  style: TextStyle(fontSize: 10),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.all(3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              dataMessage.type == "TEXT"
                                  ? GestureDetector(
                                      onLongPress: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: dataMessage.message));
                                      },
                                      child:
                                          Text(dataMessage.message.toString()))
                                  : Container(
                                      height: 200,
                                      width: 200,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  "${dataMessage.message}"),
                                              fit: BoxFit.cover)),
                                    ),
                              Text(
                                '${dataMessage.hour}:${dataMessage.minute} ນ',
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ));
  }
}
