import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:demoudp/widget/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CreateUDP extends StatefulWidget {
  const CreateUDP({super.key});

  @override
  State<CreateUDP> createState() => _CreateUDPState();
}

class _CreateUDPState extends State<CreateUDP> {
  TextEditingController _testText = TextEditingController();

  late Uint8List imagebytes = new Uint8List(0);
  var imageFireResult;
  File? file;
  String data = '';
  late String message;
  var dataArr = {};
  var dataArrCheck = {};
  var missingIndex = {};
  final _textController = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _to = TextEditingController();
  int showImage = 0;
  double percent = 0;
  // int sendIndex = 0;
  var sendIndex = {};
  // int resendIndex = 0;
  var resendIndex = {};
  late Timer timeOut;
  // List<int> dataListRefund = [];
  var dataListRefund = {};

  // var address;
  // var port;
  int totalBuffer = 0;
  int totalBufferTo = 0;
  var total = {};
  var totalToCheck = {};
  int roundTosend = 100;
  var _start = {};
  // int _end = 100;
  var _end = {};
  int percenNumber = 0;
  var allImageToSend = {};
  late int allImageToSendKey;
  List<Uint8List> sperate = [];
  late Uint8List _bytes;
  late RawDatagramSocket socket;
  var allImageToShow = [];
  void login() async {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 2222)
        .then((RawDatagramSocket socket) {
      // Set the handler for receiving data
      this.socket = socket;
      this.socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          // Read the data
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
            // setState(() {
            //   sendIndex = 0;
            // });
            sendMessage(data);
          } else if (json.decode(data)['command'] == 'success') {
            allImageToSend.remove(json.decode(data)['trans']);
          } else {
            _pushButterToImage(data);
          }
        }
      });
      var login = {
        "data": {"userName": _username.text, "password": _password.text},
        "command": "login",
      };
      this.socket.send(utf8.encode(jsonEncode(login)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
    });
  }

  void send() {
    var dataSend = {
      'data': {
        'total': allImageToSend[allImageToSendKey].length,
        'channel': _to.text,
        'trans': allImageToSendKey,
      },
      "token": _username.text,
      "command": 'sendTotal'
    };
    socket.send(utf8.encode(jsonEncode(dataSend)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
    // print('send');
  }

  void _sendTotal(var dataSendTotal) {
    // dataArr.clear();
    // dataArrCheck.clear();
    _start.addAll({json.decode(dataSendTotal)['trans']: 0});
    _end.addAll({json.decode(dataSendTotal)['trans']: roundTosend});

    setState(() {
      showImage == 0;

      // _start = 0;
      // _end = roundTosend;
      // total = json.decode(data)['total'];
      // totalToCheck = json.decode(data)['total'];
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
      // setState(() {
      //   _end = total[json.decode(data)['trans']];
      // });
    }
    // print('send total');
    _confirmToSend(dataSendTotal);
  }

  void _confirmToSend(var dataConfirmToSend) {
    missingIndex.remove(json.decode(dataConfirmToSend)['trans']);

    if (_start[json.decode(dataConfirmToSend)['trans']] >=
        total[json.decode(dataConfirmToSend)['trans']]) {
      print('Success1');
    } else {
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

      // print(dataConfirm);
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
        // setState(() {
        //   // _start = _start + roundTosend;
        //   _end = total[json.decode(data)['trans']];
        // });
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
          "channel": _to.text,
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
      this.socket.send(utf8.encode(jsonEncode(dataToSend)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
      sendIndex.update(
          json.decode(dataSend)['trans'],
          (value) =>
              int.parse(sendIndex[json.decode(dataSend)['trans']].toString()) +
              1);
      // setState(() {
      //   sendIndex++;
      // });
    }
    // print('send message');
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
          "channel": _to.text,
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
        "token": _username.text,
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
      // setState(() {
      //   resendIndex++;
      // });
    } else {
      print('resendSuccess');
    }
    // print('resend');
  }

  void _sendRefunData(String dataRefund) {
    // dataListRefund[json.decode(dataRefund)['trans']].clear();
    resendIndex.addAll({json.decode(dataRefund)['trans']: 0});
    dataListRefund.addAll(
        {json.decode(dataRefund)['trans']: json.decode(dataRefund)['message']});
    // setState(() {
    //   // address = json.decode(dataRefund)['address'];
    //   // port = json.decode(dataRefund)['port'];
    //   // resendIndex = 0;
    //   dataListRefund = [...json.decode(dataRefund)['message']];
    // });

    resend(dataRefund);
    // print('send refund');
  }

  void _resendData(String dataResend) {
    // int index = json.decode(dataResend)['index'];
    int indexAdd = json.decode(dataResend)['index'];
    // print('index Delete:' + index.toString());
    if (json.decode(dataResend)['message'].length ==
        json.decode(dataResend)['sumData']) {
      if (json.decode(dataResend)['round'] == 1) {
        waitTimeOutToCheck(dataResend);
        var resultRemove = _removeDataToCheck(dataResend);
        if (resultRemove == true) {
          if (indexAdd > dataArr.length) {
            setState(() {
              showImage = 0;
              // message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
            });
            _removeAndAdds(dataResend);
            dataArrCheck[json.decode(dataResend)['trans']]
                .add(json.decode(dataResend)['index']);
          } else {
            setState(() {
              showImage = 0;
              // message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);

              dataArrCheck[json.decode(dataResend)['trans']]
                  .add(json.decode(dataResend)['index']);
            });
            _removeAndAdds(dataResend);
          }
        }
      } else {
        var resultRemove = _removeDataToCheck(dataResend);
        if (resultRemove == true) {
          if (indexAdd > dataArr.length) {
            // setState(() {
            // message = json.decode(dataResend)['message'].toString();
            // dataArr.add(message);
            _removeAndAdds(dataResend);
            dataArrCheck[json.decode(dataResend)['trans']]
                .add(json.decode(dataResend)['index']);
            // });
          } else {
            // setState(() {
            //   message = json.decode(dataResend)['message'].toString();
            //   // dataArr.add(message);

            // });
            _removeAndAdds(dataResend);
            dataArrCheck[json.decode(dataResend)['trans']]
                .add(json.decode(dataResend)['index']);
          }
        }
      }
      if (json.decode(dataResend)['round'] ==
          json.decode(dataResend)['total']) {
        _convertToImage(dataResend);
      } else {
        print('checkTime');
      }
      // print('length DataArr' +
      //     dataArr[json.decode(dataResend)['trans']].length.toString());
    } else {
      print("NO");
    }
    // print('resendData');
  }

  Future chooseImage(BuildContext context) async {
    try {
      var image = await ImagePicker().getImage(source: ImageSource.gallery);
      file = File(image!.path);
      imagebytes = await file!.readAsBytes();
      var keyIndex;
      setState(() {
        totalBuffer = imagebytes.length;
        keyIndex = DateTime.now().millisecondsSinceEpoch;
        allImageToSendKey = keyIndex;
      });
      int chunkSize = 2000;
      for (int i = 0; i < imagebytes.length; i += chunkSize) {
        int end = i + chunkSize < imagebytes.length
            ? i + chunkSize
            : imagebytes.length;
        // chunk.add(imagebytes.sublist(i, end));
        sperate.add(imagebytes.sublist(i, end));
      }
      allImageToSend.addAll({keyIndex: sperate});
      _testText.text = sperate.length.toString();
      // print(sperate);
      // print(sperate.length);
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
        setState(() {
          String base64string = base64.encode(newList.cast<int>());
          imageFireResult = "data:image/jpg;base64,$base64string";
          //  base = base64.decode(base64string);
          String uri = imageFireResult.toString();
          _bytes = base64.decode(uri.split(',').last);
          allImageToShow.add(_bytes);
          _testText.text = imageFireResult;
          showImage = 1;
          totalBufferTo = newList.length;
          saveToStorage(base64string);
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
    // print(dataToSave);
    Uint8List bytes = base64.decode(dataToSave);
    // print(bytes);
    final dir = await getExternalStorageDirectory();
    File file = File("${dir!.path}/" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".jpg");
    // print(bytes.runtimeType);
    await file.writeAsBytes(bytes);
    print(file.path);
  }

  void _pushButterToImage(String dataBuffer) {
    // print(json.decode(dataBuffer)['round']);
    // print(json.decode(dataBuffer)['message'].runtimeType);
    // print(json.decode(dataBuffer)['round']);
    // print(json.decode(dataBuffer)['index']);
    if (json.decode(dataBuffer)['message'].length ==
        json.decode(dataBuffer)['sumData']) {
      if (json.decode(dataBuffer)['total'] ==
          json.decode(dataBuffer)['round']) {
        if (json.decode(dataBuffer)['round'] == 1) {
          waitTimeOutToCheck(dataBuffer);

          missingIndex.remove(json.decode(dataBuffer)['trans']);
          _addDataToCheck(json.decode(dataBuffer)['start'],
              json.decode(dataBuffer)['end'], json.decode(dataBuffer)['trans']);
          var result = _removeDataToCheck(dataBuffer);
          if (result == true) {
            _removeAndAdds(dataBuffer);
            dataArrCheck[json.decode(dataBuffer)['trans']]
                .add(json.decode(dataBuffer)['index']);
          }
        } else {
          var result = _removeDataToCheck(dataBuffer);
          if (result == true) {
            _removeAndAdds(dataBuffer);
            dataArrCheck[json.decode(dataBuffer)['trans']]
                .add(json.decode(dataBuffer)['index']);
          }
        }
        _convertToImage(dataBuffer);
      } else {
        if (json.decode(dataBuffer)['round'] == 1) {
          waitTimeOutToCheck(dataBuffer);
          missingIndex.remove(json.decode(dataBuffer)['trans']);
          _addDataToCheck(json.decode(dataBuffer)['start'],
              json.decode(dataBuffer)['end'], json.decode(dataBuffer)['trans']);
          var result = _removeDataToCheck(dataBuffer);
          if (result == true) {
            _removeAndAdds(dataBuffer);
            dataArrCheck[json.decode(dataBuffer)['trans']]
                .add(json.decode(dataBuffer)['index']);
          }
        } else {
          var result = _removeDataToCheck(dataBuffer);
          if (result == true) {
            _removeAndAdds(dataBuffer);
            dataArrCheck[json.decode(dataBuffer)['trans']]
                .add(json.decode(dataBuffer)['index']);
          }
        }
      }
    }
    setState(() {
      double index = double.parse(json.decode(dataBuffer)['index'].toString());
      percent = index / totalToCheck[json.decode(dataBuffer)['trans']];
      double cal = index * 100;
      percenNumber = cal ~/ totalToCheck[json.decode(dataBuffer)['trans']];
    });
    // print('pushBuffer to image');
  }

  Future<void> waitTimeOutToCheck(var dataWait) async {
    timeOut = Timer(Duration(seconds: 2), () {
      print('PrinttimeOut');
      _convertToImage(dataWait);
    });

    // and later, before the timer goes off...
    // t.cancel();
  }

  void _addDataToCheck(int start, end, var trans) {
    missingIndex.addAll({trans: []});
    for (var i = start; i < end; i++) {
      missingIndex[trans].add(i);
      // print('add data trans ${trans.toString()} index : ${i.toString()}');
    }
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
    // print(missingIndex[trans]);

    // print('number remove is :' + number.toString());
    var result = missingIndex[json.decode(removeAndCheck)['trans']]
        .remove(json.decode(removeAndCheck)['index']);
    // print('trans is :' + trans.toString());
    // print('result remove is :' + result.toString());
    return result;
  }

// 036-12-00-01876621-001
  void _refundData(var dataRef) {
    var dataRefund = {
      "data": {
        "message": missingIndex[json.decode(dataRef)['trans']],
        "channel": _to.text,
        "type": "IMAGE",
        "total": 1,
        "round": 1,
        "sumData": missingIndex[json.decode(dataRef)['trans']].length,
        "address": json.decode(dataRef)['address'],
        "port": json.decode(dataRef)['port'],
        "trans": json.decode(dataRef)['trans'],
      },
      "token": _username.text,
      "command": "refund"
    };
    this.socket.send(utf8.encode(jsonEncode(dataRefund)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
    // print('refund data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              setState(() {
                showImage = 0;
              });
              allImageToShow.clear();
              _end.clear();
              missingIndex.clear();
            },
            icon: Icon(Icons.cancel)),
        IconButton(
            onPressed: () {
              print(missingIndex);
              print(missingIndex.length);
            },
            icon: Icon(Icons.history)),
        IconButton(
            onPressed: () {
              // var results1 = {
              //   1: 3,
              //   2: [6, 7, 8, 9],
              // };
              // results1[2]!.remove();
              // print(results1);
            },
            icon: Icon(Icons.check)),
        IconButton(
            onPressed: () {
              List<dynamic> newList = [];

              for (int i = 0; i < dataArr.length; i++) {
                newList.addAll(jsonDecode(dataArr[i].toString()));
              }
              setState(() {
                String base64string = base64.encode(newList.cast<int>());
                imageFireResult = "data:image/jpg;base64,$base64string";
                String uri = imageFireResult.toString();
                _bytes = base64.decode(uri.split(',').last);
                _testText.text = imageFireResult;
                showImage = 1;
                totalBufferTo = newList.length;
              });
            },
            icon: Icon(Icons.send)),
        IconButton(
            onPressed: () {
              // chunk.clear();
              sperate.clear();
              allImageToSend.clear();
              chooseImage(context);
            },
            icon: Icon((Icons.get_app)))
      ]),
      body: SingleChildScrollView(
        child: Column(children: [
          showImage == 0
              ? CircularPercentIndicator(
                  radius: 20,
                  lineWidth: 5,
                  percent: percent,
                  progressColor: Colors.green,
                  center: Text("${percenNumber}%"),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: allImageToShow.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        child: Image.memory(
                          allImageToShow[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
          // : Container(
          //     height: 200,
          //     width: 200,
          //     child: Image.memory(
          //       _bytes,
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          SizedBox(height: 20),
          TextField(
            controller: _testText,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _username,
              decoration: InputDecoration(hintText: "ຜຸ້ສົ່ງ"),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _password,
              decoration: InputDecoration(hintText: "ລະຫັດຜ່ານ"),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: _to,
              decoration: InputDecoration(hintText: "ຜຸ້ຮັບ"),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter message',
              ),
            ),
          ),
          TextButton(
              onPressed: () {
                if (_username.text.isNotEmpty && _password.text.isNotEmpty) {
                  login();
                }
              },
              child: Text("LOGIN")),
          TextButton(
              onPressed: () {
                if (_textController.text.isNotEmpty && _to.text.isNotEmpty) {
                  if (sperate.length == 0 || sperate == null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("ກະລຸນາເລືອກຮຸບພາບ"),
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
                    // setState(() {
                    //   sendIndex = 0;
                    // });
                    sendIndex.addAll({allImageToSendKey: 0});
                    print('ho');

                    // sendMessage();
                    send();
                  }
                }
              },
              child: Text("send")),
          Text(totalBuffer.toString()),
          Text(totalBufferTo.toString())
        ]),
      ),
    );
  }
}
