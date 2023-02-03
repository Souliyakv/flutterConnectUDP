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
  int sendIndex = 0;
  int resendIndex = 0;
  late Timer timeOut;
  List<int> dataListRefund = [];
  var address;
  var port;
  int totalBuffer = 0;
  int totalBufferTo = 0;
  var total = {};
  var totalToCheck = {};
  int roundTosend = 100;
  int _start = 0;
  int _end = 100;
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
            sendMessage();
          } else if (json.decode(data)['command'] == 'refund') {
            _sendRefunData(data);
          } else if (json.decode(data)['command'] == 'resend') {
            _resendData(data);
          } else if (json.decode(data)['command'] == 'ackResend') {
            resend();
          } else if (json.decode(data)['command'] == 'sendTotal') {
            _sendTotal();
          } else if (json.decode(data)['command'] == 'confirmToSend') {
            setState(() {
              sendIndex = 0;
            });
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
    setState(() {
      showImage == 0;

      _start = 0;
      _end = roundTosend;
      // total = json.decode(data)['total'];
      // totalToCheck = json.decode(data)['total'];
    });
    dataArrCheck.addAll({json.decode(data)['trans']: []});
    total.addAll({json.decode(data)['trans']: json.decode(data)['total']});

    totalToCheck
        .addAll({json.decode(data)['trans']: json.decode(data)['total']});
    _genData(totalToCheck[json.decode(data)['trans']]);
    if (total[json.decode(data)['trans']] <= _end) {
      setState(() {
        _end = total[json.decode(data)['trans']];
      });
    }
    _confirmToSend();
  }

  void _confirmToSend() {
    missingIndex.remove(json.decode(data)['trans']);

    if (_start >= total[json.decode(data)['trans']]) {
      print('Success1');
    } else {
      var dataConfirm = {
        'data': {
          "start": _start,
          "end": _end,
          "address": json.decode(data)['address'],
          "port": json.decode(data)['port'],
          "trans": json.decode(data)['trans']
        },
        "command": 'confirmToSend'
      };
      print(dataConfirm);
      socket.send(utf8.encode(jsonEncode(dataConfirm)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);

      int checkEnd = _end + roundTosend;
      if (checkEnd >= total[json.decode(data)['trans']]) {
        setState(() {
          _start = _start + roundTosend;
          _end = total[json.decode(data)['trans']];
        });
      } else {
        setState(() {
          _start = _start + roundTosend;
          _end = _end + roundTosend;
        });
      }
    }
  }

  void sendMessage() {
    int sendIndexData = json.decode(data)['start'] + sendIndex;
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
          "round": sendIndex + 1,
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
      setState(() {
        sendIndex++;
      });
    }
  }

  void resend() {
    if (resendIndex != dataListRefund.length) {
      int dataIndex = dataListRefund[resendIndex];
      var dataResend = {
        "data": {
          "message": allImageToSend[json.decode(data)['trans']][dataIndex],
          "channel": _to.text,
          "type": "IMAGE",
          "total": dataListRefund.length,
          "round": resendIndex + 1,
          "index": dataListRefund[resendIndex],
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
      setState(() {
        resendIndex++;
      });
    } else {
      print('resendSuccess');
    }
  }

  void _sendRefunData(String dataRefund) {
    dataListRefund.clear();
    setState(() {
      address = json.decode(dataRefund)['address'];
      port = json.decode(dataRefund)['port'];
      resendIndex = 0;
      dataListRefund = [...json.decode(dataRefund)['message']];
    });

    resend();
  }

  void _resendData(String dataResend) {
    // int index = json.decode(dataResend)['index'];
    int indexAdd = json.decode(dataResend)['index'];
    // print('index Delete:' + index.toString());
    if (json.decode(dataResend)['message'].length ==
        json.decode(dataResend)['sumData']) {
      if (json.decode(dataResend)['round'] == 1) {
        waitTimeOutToCheck();
        var resultRemove = _removeDataToCheck(json.decode(dataResend)['index']);
        if (resultRemove == true) {
          if (indexAdd > dataArr.length) {
            setState(() {
              showImage = 0;
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              _removeAndAdds(indexAdd, message);
              dataArrCheck[json.decode(dataResend)['trans']]
                  .add(json.decode(dataResend)['index']);
            });
          } else {
            setState(() {
              showImage = 0;
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              _removeAndAdds(indexAdd, message);
              dataArrCheck[json.decode(dataResend)['trans']]
                  .add(json.decode(dataResend)['index']);
            });
          }
        }
      } else {
        var resultRemove = _removeDataToCheck(json.decode(dataResend)['index']);
        if (resultRemove == true) {
          if (indexAdd > dataArr.length) {
            setState(() {
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              _removeAndAdds(indexAdd, message);
              dataArrCheck[json.decode(dataResend)['trans']]
                  .add(json.decode(dataResend)['index']);
            });
          } else {
            setState(() {
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              _removeAndAdds(indexAdd, message);
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
          var result = _removeDataToCheck(json.decode(dataBuffer)['index']);
          if (result == true) {
            _removeAndAdds(json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString());
            dataArrCheck[json.decode(dataBuffer)['trans']]
                .add(json.decode(dataBuffer)['index']);
          }
        } else {
          var result = _removeDataToCheck(json.decode(dataBuffer)['index']);
          if (result == true) {
            _removeAndAdds(json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString());
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
          var result = _removeDataToCheck(json.decode(dataBuffer)['index']);
          if (result == true) {
            _removeAndAdds(json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString());
            dataArrCheck[json.decode(dataBuffer)['trans']]
                .add(json.decode(dataBuffer)['index']);
          }
        } else {
          var result = _removeDataToCheck(json.decode(dataBuffer)['index']);
          if (result == true) {
            _removeAndAdds(json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString());
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

  void _addDataToCheck(int _start, _end, var trans) {
    missingIndex.addAll({trans: []});
    for (var i = _start; i < _end; i++) {
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

  _removeAndAdds(int index, var message) {
    var result = dataArr[json.decode(data)['trans']].remove(index.toString());
    if (result == true) {
      dataArr[json.decode(data)['trans']].insert(index, message);
    }
  }

  _removeDataToCheck(int number) {
    var result = missingIndex[json.decode(data)['trans']].remove(number);
    return result;
  }

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
                    setState(() {
                      sendIndex = 0;
                    });
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
