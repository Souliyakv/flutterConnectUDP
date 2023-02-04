import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:demoudp/widget/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  List<int> dataListRefund = [];
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
    RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 2222)
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
            sendMessage();
          } else if (json.decode(data)['command'] == 'refund') {
            _sendRefunData(data);
          } else if (json.decode(data)['command'] == 'resend') {
            _resendData(data);
          } else if (json.decode(data)['command'] == 'ackResend') {
            resend(json.decode(data)['port'], json.decode(data)['address']);
          } else if (json.decode(data)['command'] == 'sendTotal') {
            _sendTotal();
          } else if (json.decode(data)['command'] == 'confirmToSend') {
            sendIndex.addAll({json.decode(data)['trans']: 0});
            // setState(() {
            //   sendIndex = 0;
            // });
            sendMessage();
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
    var data = {
      'data': {
        'total': allImageToSend[allImageToSendKey].length,
        'channel': _to.text,
        'trans': allImageToSendKey,
      },
      "token": _username.text,
      "command": 'sendTotal'
    };
    socket.send(utf8.encode(jsonEncode(data)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }

  void _sendTotal() {
    dataArr.clear();
    dataArrCheck.clear();
    _start.addAll({json.decode(data)['trans']: 0});
    _end.addAll({json.decode(data)['trans']: roundTosend});

    setState(() {
      showImage == 0;

      // _start = 0;
      // _end = roundTosend;
      // total = json.decode(data)['total'];
      // totalToCheck = json.decode(data)['total'];
    });

    dataArrCheck.addAll({json.decode(data)['trans']: []});
    total.addAll({json.decode(data)['trans']: json.decode(data)['total']});

    totalToCheck
        .addAll({json.decode(data)['trans']: json.decode(data)['total']});
    _genData(totalToCheck[json.decode(data)['trans']]);
    if (total[json.decode(data)['trans']] <= _end[json.decode(data)['trans']]) {
      _end.update(json.decode(data)['trans'],
          (value) => total[json.decode(data)['trans']]);
      // setState(() {
      //   _end = total[json.decode(data)['trans']];
      // });
    }

    _confirmToSend();
  }

  void _confirmToSend() {
    missingIndex.remove(json.decode(data)['trans']);

    if (_start[json.decode(data)['trans']] >=
        total[json.decode(data)['trans']]) {
      print('Success1');
    } else {
      var dataConfirm = {
        'data': {
          "start": _start[json.decode(data)['trans']],
          "end": _end[json.decode(data)['trans']],
          "address": json.decode(data)['address'],
          "port": json.decode(data)['port'],
          "trans": json.decode(data)['trans']
        },
        "command": 'confirmToSend'
      };

      print(dataConfirm);
      socket.send(utf8.encode(jsonEncode(dataConfirm)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);

      int checkEnd = _end[json.decode(data)['trans']] + roundTosend;

      if (checkEnd >= total[json.decode(data)['trans']]) {
        _start.update(
            json.decode(data)['trans'],
            (value) =>
                int.parse(_start[json.decode(data)['trans']].toString()) +
                roundTosend);
        _end.update(json.decode(data)['trans'],
            (value) => total[json.decode(data)['trans']]);
        // setState(() {
        //   // _start = _start + roundTosend;
        //   _end = total[json.decode(data)['trans']];
        // });
      } else {
        _start.update(
            json.decode(data)['trans'],
            (value) =>
                int.parse(_start[json.decode(data)['trans']].toString()) +
                roundTosend);
        _end.update(
            json.decode(data)['trans'],
            (value) =>
                int.parse(_end[json.decode(data)['trans']].toString()) +
                roundTosend);
        // setState(() {
        //   // _start = _start + roundTosend;
        //   _end = _end + roundTosend;
        // });
      }
    }
  }

  void sendMessage() {
    int sendIndexData =
        json.decode(data)['start'] + sendIndex[json.decode(data)['trans']];
    print(sendIndexData);

    int total = json.decode(data)['end'] - json.decode(data)['start'];
    print(data);
    if (sendIndexData < json.decode(data)['end']) {
      var dataToSend = {
        "data": {
          "message": allImageToSend[json.decode(data)['trans']][sendIndexData],
          "channel": _to.text,
          "type": "IMAGE",
          "index": sendIndexData,
          "total": total,
          "round": sendIndex[json.decode(data)['trans']] + 1,
          "start": json.decode(data)['start'],
          "end": json.decode(data)['end'],
          "sumData":
              allImageToSend[json.decode(data)['trans']][sendIndexData].length,
          "address": json.decode(data)['address'],
          "port": json.decode(data)['port'],
          "trans": json.decode(data)['trans'],
        },
        "command": "send"
      };
      this.socket.send(utf8.encode(jsonEncode(dataToSend)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
      sendIndex.update(
          json.decode(data)['trans'],
          (value) =>
              int.parse(sendIndex[json.decode(data)['trans']].toString()) + 1);
      // setState(() {
      //   sendIndex++;
      // });
    }
  }

  void resend(var port, address) {
    if (resendIndex[json.decode(data)['trans']] != dataListRefund.length) {
      int dataIndex = dataListRefund[resendIndex[json.decode(data)['trans']]];
      var dataResend = {
        "data": {
          "message": allImageToSend[json.decode(data)['trans']][dataIndex],
          "channel": _to.text,
          "type": "IMAGE",
          "total": dataListRefund.length,
          "round": resendIndex[json.decode(data)['trans']] + 1,
          "index": dataListRefund[resendIndex[json.decode(data)['trans']]],
          "sumData":
              allImageToSend[json.decode(data)['trans']][dataIndex].length,
          "address": address,
          "port": port,
          'trans': json.decode(data)['trans']
        },
        "token": _username.text,
        "command": "resend"
      };
      this.socket.send(utf8.encode(jsonEncode(dataResend)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
      resendIndex.update(
          json.decode(data)['trans'],
          (value) =>
              int.parse(resendIndex[json.decode(data)['trans']].toString()) +
              1);
      // setState(() {
      //   resendIndex++;
      // });
    } else {
      print('resendSuccess');
    }
  }

  void _sendRefunData(String dataRefund) {
    dataListRefund.clear();
    resendIndex.addAll({json.decode(dataRefund)['trans']: 0});
    setState(() {
      // address = json.decode(dataRefund)['address'];
      // port = json.decode(dataRefund)['port'];
      // resendIndex = 0;
      dataListRefund = [...json.decode(dataRefund)['message']];
    });

    resend(json.decode(dataRefund)['port'], json.decode(dataRefund)['address']);
  }

  void _resendData(String dataResend) {
    // int index = json.decode(dataResend)['index'];
    int indexAdd = json.decode(dataResend)['index'];
    // print('index Delete:' + index.toString());
    if (json.decode(dataResend)['message'].length ==
        json.decode(dataResend)['sumData']) {
      if (json.decode(dataResend)['round'] == 1) {
        waitTimeOutToCheck();
        var resultRemove = _removeDataToCheck(
            json.decode(dataResend)['index'], json.decode(dataResend)['trans']);
        if (resultRemove == true) {
          if (indexAdd > dataArr.length) {
            setState(() {
              showImage = 0;
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              _removeAndAdds(
                  indexAdd, message, json.decode(dataResend)['trans']);
              dataArrCheck[json.decode(dataResend)['trans']]
                  .add(json.decode(dataResend)['index']);
            });
          } else {
            setState(() {
              showImage = 0;
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              _removeAndAdds(
                  indexAdd, message, json.decode(dataResend)['trans']);
              dataArrCheck[json.decode(dataResend)['trans']]
                  .add(json.decode(dataResend)['index']);
            });
          }
        }
      } else {
        var resultRemove = _removeDataToCheck(
            json.decode(dataResend)['index'], json.decode(dataResend)['trans']);
        if (resultRemove == true) {
          if (indexAdd > dataArr.length) {
            setState(() {
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              _removeAndAdds(
                  indexAdd, message, json.decode(dataResend)['trans']);
              dataArrCheck[json.decode(dataResend)['trans']]
                  .add(json.decode(dataResend)['index']);
            });
          } else {
            setState(() {
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              _removeAndAdds(
                  indexAdd, message, json.decode(dataResend)['trans']);
              dataArrCheck[json.decode(dataResend)['trans']]
                  .add(json.decode(dataResend)['index']);
            });
          }
        }
      }
      if (json.decode(dataResend)['round'] ==
          json.decode(dataResend)['total']) {
        _convertToImage();
      } else {
        print('checkTime');
      }
      // print('length DataArr' +
      //     dataArr[json.decode(dataResend)['trans']].length.toString());
    } else {
      print("NO");
    }
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

  void sendSuccess(var data) {
    var dataSuccess = {
      'data': {
        'trans': json.decode(data)['trans'],
        'address': json.decode(data)['address'],
        'port': json.decode(data)['port'],
      },
      'command': 'success'
    };
    this.socket.send(utf8.encode(jsonEncode(dataSuccess)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }

  void _convertToImage() {
    timeOut.cancel();
    List<dynamic> newList = [];
    newList.clear();

    if (missingIndex[json.decode(data)['trans']] == null ||
        missingIndex[json.decode(data)['trans']].length == 0) {
      if (dataArrCheck[json.decode(data)['trans']].length ==
          totalToCheck[json.decode(data)['trans']]) {
        for (int i = 0; i < dataArr[json.decode(data)['trans']].length; i++) {
          newList.addAll(
              jsonDecode(dataArr[json.decode(data)['trans']][i].toString()));
        }

        sendSuccess(data);
        missingIndex.remove(json.decode(data)['trans']);
        dataArr.remove(json.decode(data)['trans']);
        dataArrCheck.remove(json.decode(data)['trans']);
        setState(() {
          String base64string = base64.encode(newList.cast<int>());
          imageFireResult = "data:image/jpg;base64,$base64string";
          String uri = imageFireResult.toString();
          _bytes = base64.decode(uri.split(',').last);
          allImageToShow.add(_bytes);
          _testText.text = imageFireResult;
          showImage = 1;
          totalBufferTo = newList.length;
        });
        newList.clear();
      } else {
        _confirmToSend();
      }
    } else {
      _refundData();
    }
  }

  void _pushButterToImage(String dataBuffer) {
    // print(json.decode(dataBuffer)['round']);
    // print(json.decode(dataBuffer)['message'].runtimeType);
    if (json.decode(dataBuffer)['message'].length ==
        json.decode(dataBuffer)['sumData']) {
      if (json.decode(dataBuffer)['total'] ==
          json.decode(dataBuffer)['round']) {
        if (json.decode(dataBuffer)['round'] == 1) {
          waitTimeOutToCheck();

          missingIndex.remove(json.decode(dataBuffer)['trans']);
          _addDataToCheck(json.decode(dataBuffer)['start'],
              json.decode(dataBuffer)['end'], json.decode(dataBuffer)['trans']);
          var result = _removeDataToCheck(json.decode(dataBuffer)['index'],
              json.decode(dataBuffer)['trans']);
          if (result == true) {
            _removeAndAdds(
                json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString(),
                json.decode(dataBuffer)['trans']);
            dataArrCheck[json.decode(dataBuffer)['trans']]
                .add(json.decode(dataBuffer)['index']);
          }
        } else {
          var result = _removeDataToCheck(json.decode(dataBuffer)['index'],
              json.decode(dataBuffer)['trans']);
          if (result == true) {
            _removeAndAdds(
                json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString(),
                json.decode(dataBuffer)['trans']);
            dataArrCheck[json.decode(dataBuffer)['trans']]
                .add(json.decode(dataBuffer)['index']);
          }
        }
        _convertToImage();
      } else {
        if (json.decode(dataBuffer)['round'] == 1) {
          waitTimeOutToCheck();
          missingIndex.remove(json.decode(dataBuffer)['trans']);
          _addDataToCheck(json.decode(dataBuffer)['start'],
              json.decode(dataBuffer)['end'], json.decode(dataBuffer)['trans']);
          var result = _removeDataToCheck(json.decode(dataBuffer)['index'],
              json.decode(dataBuffer)['trans']);
          if (result == true) {
            _removeAndAdds(
                json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString(),
                json.decode(dataBuffer)['trans']);
            dataArrCheck[json.decode(dataBuffer)['trans']]
                .add(json.decode(dataBuffer)['index']);
          }
        } else {
          var result = _removeDataToCheck(json.decode(dataBuffer)['index'],
              json.decode(dataBuffer)['trans']);
          if (result == true) {
            _removeAndAdds(
                json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString(),
                json.decode(dataBuffer)['trans']);
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
  }

  Future<void> waitTimeOutToCheck() async {
    timeOut = Timer(Duration(seconds: 2), () {
      print('PrinttimeOut');
      _convertToImage();
    });

    // and later, before the timer goes off...
    // t.cancel();
  }

  void _addDataToCheck(int start, end, var trans) {
    missingIndex.addAll({trans: []});
    for (var i = start; i < end; i++) {
      missingIndex[trans].add(i);
    }
  }

  void _genData(int number) {
    dataArr.addAll({json.decode(data)['trans']: []});
    for (var i = 0; i < number; i++) {
      dataArr[json.decode(data)['trans']].add(i.toString());
    }

    // print('all data is :'+dataArr.toString());
  }

  _removeAndAdds(int index, var message, trans) {
    var result = dataArr[trans].remove(index.toString());
    //  print('number remove is :' + index.toString());
    // print('result remove is :' + result.toString());
    // print(dataArr[trans]);
    if (result == true) {
      dataArr[trans].insert(index, message);
    }
  }

  _removeDataToCheck(int number, var trans) {
    print(missingIndex[trans]);

    print('number remove is :' + number.toString());
    var result = missingIndex[trans].remove(number);
    // print('trans is :' + trans.toString());
    print('result remove is :' + result.toString());
    return result;
  }

// 036-12-00-01876621-001
  void _refundData() {
    var dataRefund = {
      "data": {
        "message": missingIndex[json.decode(data)['trans']],
        "channel": _to.text,
        "type": "IMAGE",
        "total": 1,
        "round": 1,
        "sumData": missingIndex[json.decode(data)['trans']].length,
        "address": json.decode(data)['address'],
        "port": json.decode(data)['port'],
        "trans": json.decode(data)['trans'],
      },
      "token": _username.text,
      "command": "refund"
    };
    this.socket.send(utf8.encode(jsonEncode(dataRefund)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
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
