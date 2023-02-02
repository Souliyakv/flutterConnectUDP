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
  List<String> dataArr = [];
  List<int> dataArrCheck = [];
  List<int> missing = [];
  List<int> missingIndex = [];
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
  late int total;
  late int totalToCheck;
  int roundTosend = 100;
  int _start = 0;
  int _end = 100;
  int percenNumber = 0;

  List<Uint8List> sperate = [];
  late Uint8List _bytes;
  late RawDatagramSocket socket;
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
            resend();
          } else if (json.decode(data)['command'] == 'sendTotal') {
            _sendTotal();
          } else if (json.decode(data)['command'] == 'confirmToSend') {
            setState(() {
              sendIndex = 0;
            });
            sendMessage();
          } else {
            _pushButterToImage(data);
            // print(json.decode(data)['message']);
            // _confirmToSend();
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
        'total': sperate.length,
        'channel': _to.text,
        'trans': '1234',
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
      total = json.decode(data)['total'];
      totalToCheck = json.decode(data)['total'];
    });
    _genData(totalToCheck);
    if (total <= _end) {
      setState(() {
        _end = total;
      });
    }
    _confirmToSend();
  }

  void _confirmToSend() {
    missingIndex.clear();

    if (_start >= total) {
      print('Success1');
    } else {
      var dataConfirm = {
        'data': {
          "start": _start,
          "end": _end,
          "address": json.decode(data)['address'],
          "port": json.decode(data)['port'],
          "trans":json.decode(data)['trans']
        },
        "command": 'confirmToSend'
      };
      print('confirm');
      print(dataConfirm);
      socket.send(utf8.encode(jsonEncode(dataConfirm)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);

      int checkEnd = _end + roundTosend;
      if (checkEnd >= total) {
        setState(() {
          _start = _start + roundTosend;
          _end = total;
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
        'trans': '12345',
        "data": {
          "message": sperate[sendIndexData],
          "channel": _to.text,
          "type": "IMAGE",
          "index": sendIndexData,
          "total": total,
          "round": sendIndex + 1,
          "start": json.decode(data)['start'],
          "end": json.decode(data)['end'],
          "sumData": sperate[sendIndexData].length,
          "address": json.decode(data)['address'],
          "port": json.decode(data)['port']
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

  // void sendMessage() {
  //   if (sendIndex != sperate.length) {
  //     // print(sperate[sendIndex].length);
  //     // print(sendIndex);
  //     var data = {
  //       'trans': '12345',
  //       "data": {
  //         "message": sperate[sendIndex],
  //         "channel": _to.text,
  //         "type": "IMAGE",
  //         "total": sperate.length,
  //         "round": sendIndex + 1,
  //         "sumData": sperate[sendIndex].length
  //       },
  //       "token": _username.text,
  //       "command": "send"
  //     };
  //     this.socket.send(utf8.encode(jsonEncode(data)),
  //         InternetAddress("${IpAddress().ipAddress}"), 2222);
  //     setState(() {
  //       sendIndex++;
  //     });
  //   } else {
  //     print("Success");
  //     // sperate.clear();
  //   }
  // }

  // void sendMessage() async {
  //   Timer.periodic(new Duration(milliseconds: 150), (timer) {
  //     int index = int.parse(timer.tick.toString());
  //     index = index - 1;
  //     if (index < sperate.length) {
  //       var data = {
  //         'trans': '12345',
  //         "data": {
  //           "message": sperate[index],
  //           "channel": _to.text,
  //           "type": "IMAGE",
  //           "total": sperate.length,
  //           "round": index + 1,
  //           "sumData":sperate[index].length
  //         },
  //         "token": _username.text,
  //         "command": "send"
  //       };
  //       this.socket.send(utf8.encode(jsonEncode(data)),
  //           InternetAddress("${IpAddress().ipAddress}"), 2222);
  //       //  print('hello' + timer.tick.toString());
  //     } else {
  //       sperate = [];
  //       timer.cancel();
  //     }
  //   });
  //   // });
  // }

  void resend() {
    if (resendIndex != dataListRefund.length) {
      int dataIndex = dataListRefund[resendIndex];
      var dataResend = {
        
        "data": {
          "message": sperate[dataIndex],
          "channel": _to.text,
          "type": "IMAGE",
          "total": dataListRefund.length,
          "round": resendIndex + 1,
          "index": dataListRefund[resendIndex],
          "sumData": sperate[dataIndex].length,
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
              dataArrCheck.add(json.decode(dataResend)['index']);
            });
          } else {
            setState(() {
              showImage = 0;
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              _removeAndAdds(indexAdd, message);
              dataArrCheck.add(json.decode(dataResend)['index']);
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
              dataArrCheck.add(json.decode(dataResend)['index']);
            });
          } else {
            setState(() {
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              _removeAndAdds(indexAdd, message);
              dataArrCheck.add(json.decode(dataResend)['index']);
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
      print('length DataArr' + dataArr.length.toString());
    } else {
      print("NO");
    }
  }

  Future chooseImage(BuildContext context) async {
    try {
      var image = await ImagePicker().getImage(source: ImageSource.gallery);
      file = File(image!.path);
      imagebytes = await file!.readAsBytes();
      setState(() {
        totalBuffer = imagebytes.length;
      });
      int chunkSize = 2000;
      for (int i = 0; i < imagebytes.length; i += chunkSize) {
        int end = i + chunkSize < imagebytes.length
            ? i + chunkSize
            : imagebytes.length;
        // chunk.add(imagebytes.sublist(i, end));
        sperate.add(imagebytes.sublist(i, end));
      }
      _testText.text = sperate.length.toString();
      // print(sperate);
      // print(sperate.length);
    } catch (e) {
      print(e);
    }
  }

  void _convertToImage() {
    timeOut.cancel();
    List<dynamic> newList = [];
    newList.clear();
    if (missingIndex == null || missingIndex.length == 0) {
      if (dataArrCheck.length == totalToCheck) {
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
        });
      } else {
        _confirmToSend();
      }
    } else {
      _refundData();
    }

    // print(newList.runtimeType);
    // print(newList.length);
    // print(json.decode(data)['total'].toString());
    // print(Check.length);
    // print(Check);
  }

  // void _pushButterToImage(String dataBuffer) {
  //   // print(json.decode(dataBuffer)['message']);
  //   if (json.decode(dataBuffer)['message'].length ==
  //       json.decode(dataBuffer)['sumData']) {
  //     if (json.decode(dataBuffer)['round'] == 1) {
  //       waitTimeOutToCheck();
  //       dataArr.clear();
  //       missing.clear();
  //       _addDataToCheck(json.decode(dataBuffer)['total']);
  //       var resultRemove = _removeDataToCheck(1);
  //       if (resultRemove == true) {
  //         setState(() {
  //           percent = 0;
  //           message = json.decode(dataBuffer)['message'].toString();
  //           dataArr.add(message);
  //         });
  //       }
  //     } else {
  //       var resultRemove = _removeDataToCheck(json.decode(dataBuffer)['round']);
  //       if (resultRemove == true) {
  //         setState(() {
  //           double round =
  //               double.parse(json.decode(dataBuffer)['round'].toString());
  //           double numtotal =
  //               double.parse(json.decode(dataBuffer)['total'].toString());
  //           percent = round / numtotal;
  //           message = json.decode(dataBuffer)['message'].toString();
  //           dataArr.add(message);
  //         });
  //       }
  //     }
  //     // _convertToImage();
  //     if (json.decode(dataBuffer)['round'] ==
  //         json.decode(dataBuffer)['total']) {
  //       _convertToImage();
  //     } else {
  //       print('checkTime');
  //     }
  //   } else {
  //     print("NO");
  //   }
  // }

  void _pushButterToImage(String dataBuffer) {
    // print(json.decode(dataBuffer)['round']);
    // print(json.decode(dataBuffer)['message'].runtimeType);
    if (json.decode(dataBuffer)['message'].length ==
        json.decode(dataBuffer)['sumData']) {
      if (json.decode(dataBuffer)['total'] ==
          json.decode(dataBuffer)['round']) {
        if (json.decode(dataBuffer)['round'] == 1) {
          // waitTimeOutToCheck();

          missingIndex.clear();
          _addDataToCheck(
              json.decode(dataBuffer)['start'], json.decode(dataBuffer)['end']);
          var result = _removeDataToCheck(json.decode(dataBuffer)['index']);
          if (result == true) {
            _removeAndAdds(json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString());
            dataArrCheck.add(json.decode(dataBuffer)['index']);
          }
        } else {
          var result = _removeDataToCheck(json.decode(dataBuffer)['index']);
          if (result == true) {
            _removeAndAdds(json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString());
            dataArrCheck.add(json.decode(dataBuffer)['index']);
          }
        }
        _convertToImage();
      } else {
        if (json.decode(dataBuffer)['round'] == 1) {
          waitTimeOutToCheck();
          missingIndex.clear();
          _addDataToCheck(
              json.decode(dataBuffer)['start'], json.decode(dataBuffer)['end']);
          var result = _removeDataToCheck(json.decode(dataBuffer)['index']);
          if (result == true) {
            _removeAndAdds(json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString());
            dataArrCheck.add(json.decode(dataBuffer)['index']);
          }
        } else {
          var result = _removeDataToCheck(json.decode(dataBuffer)['index']);
          if (result == true) {
            _removeAndAdds(json.decode(dataBuffer)['index'],
                json.decode(dataBuffer)['message'].toString());
            dataArrCheck.add(json.decode(dataBuffer)['index']);
          }
        }
      }
    }
    setState(() {
      double index = double.parse(json.decode(dataBuffer)['index'].toString());
      percent = index / totalToCheck;
      double cal = index * 100;
      percenNumber = cal ~/ totalToCheck;
    });
  }

  Future<void> waitTimeOutToCheck() async {
    timeOut = Timer(Duration(seconds: 5), () {
      print('PrinttimeOut');
      _convertToImage();
    });

    // and later, before the timer goes off...
    // t.cancel();
  }

  void _addDataToCheck(int _start, _end) {
    for (var i = _start; i < _end; i++) {
      missingIndex.add(i);
    }
  }

  void _genData(int number) {
    for (var i = 0; i < number; i++) {
      dataArr.add(i.toString());
    }
  }

  _removeAndAdds(int index, var message) {
    var result = dataArr.remove(index.toString());
    if (result == true) {
      dataArr.insert(index, message);
    }
  }

  _removeDataToCheck(int number) {
    var result = missingIndex.remove(number);
    return result;
  }

  void _refundData() {
    var dataRefund = {
      'trans': '12345',
      "data": {
        "message": missingIndex,
        "channel": _to.text,
        "type": "IMAGE",
        "total": 1,
        "round": 1,
        "sumData": missingIndex.length,
        "address": json.decode(data)['address'],
        "port": json.decode(data)['port']
      },
      "token": _username.text,
      "command": "refund"
    };
    this.socket.send(utf8.encode(jsonEncode(dataRefund)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
    print(missing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              print(dataArr.length);
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
              // _removeDataToCheck();
              _refundData();
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
              // List<dynamic> newList = [];
              // var a = [];

              // for (int i = 0; i < dataArr.length; i++) {
              //   newList.addAll(jsonDecode(dataArr[i]));
              // }
              // setState(() {
              //   String base64string = base64.encode(newList.cast<int>());
              //   imageFireResult = "data:image/jpg;base64,$base64string";
              //   String uri = imageFireResult.toString();
              //   _bytes = base64.decode(uri.split(',').last);
              //   _testText.text = imageFireResult;
              //   showImage = 1;
              // });
            },
            icon: Icon(Icons.send)),
        IconButton(
            onPressed: () {
              // chunk.clear();
              sperate.clear();
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
              : Container(
                  height: 200,
                  width: 200,
                  child: Image.memory(
                    _bytes,
                    fit: BoxFit.cover,
                  ),
                ),
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
                  setState(() {
                    sendIndex = 0;
                  });
                  // sendMessage();
                  send();
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
