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
  List<int> missing = [];
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

  List<Uint8List> sperate = [];
  late Uint8List _bytes;
  late RawDatagramSocket socket;
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
          print(json.decode(data)['command']);
          if (json.decode(data)['command'] == "ack") {
            sendMessage();
          } else if (json.decode(data)['command'] == 'refund') {
            _sendRefunData(data);
          } else if (json.decode(data)['command'] == 'resend') {
            _resendData(data);
          } else if (json.decode(data)['command'] == 'ackResend') {
            resend();
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

  void sendMessage() {
    if (sendIndex != sperate.length) {
      // print(sperate[sendIndex].length);
      // print(sendIndex);
      var data = {
        'trans': '12345',
        "data": {
          "message": sperate[sendIndex],
          "channel": _to.text,
          "type": "IMAGE",
          "total": sperate.length,
          "round": sendIndex + 1,
          "sumData": sperate[sendIndex].length
        },
        "token": _username.text,
        "command": "send"
      };
      this.socket.send(utf8.encode(jsonEncode(data)),
          InternetAddress("${IpAddress().ipAddress}"), 2222);
      setState(() {
        sendIndex++;
      });
    } else {
      print("Success");
      // sperate.clear();
    }
  }

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
      int dataIndex = dataListRefund[resendIndex] - 1;
      var dataResend = {
        'trans': '12345',
        "data": {
          "message": sperate[dataIndex],
          "channel": _to.text,
          "type": "IMAGE",
          "total": dataListRefund.length,
          "round": resendIndex + 1,
          "index": dataListRefund[resendIndex],
          "sumData": sperate[dataIndex].length,
          "address": address,
          "port": port
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
    int index = json.decode(dataResend)['index'];
    int indexAdd = json.decode(dataResend)['index'] - 2;
    // print('index Delete:' + index.toString());
    print("index" + indexAdd.toString());
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
              dataArr.add(message);
            });
          } else {
            setState(() {
              showImage = 0;
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              dataArr.insert(indexAdd, message);
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
              dataArr.add(message);
            });
          } else {
            setState(() {
              message = json.decode(dataResend)['message'].toString();
              // dataArr.add(message);
              dataArr.insert(indexAdd, message);
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

    if (missing == null || missing.length == 0) {
      for (int i = 0; i < dataArr.length; i++) {
        newList.addAll(jsonDecode(dataArr[i]));
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
      _refundData();
    }

    // print(newList.runtimeType);
    // print(newList.length);
    // print(json.decode(data)['total'].toString());
    // print(Check.length);
    // print(Check);
  }

  void _pushButterToImage(String dataBuffer) {
    // print(json.decode(dataBuffer)['message']);
    if (json.decode(dataBuffer)['message'].length ==
        json.decode(dataBuffer)['sumData']) {
      if (json.decode(dataBuffer)['round'] == 1) {
        waitTimeOutToCheck();

        dataArr.clear();
        missing.clear();
        _addDataToCheck(json.decode(dataBuffer)['total']);
        var resultRemove = _removeDataToCheck(1);
        if (resultRemove == true) {
          setState(() {
            percent = 0;
            message = json.decode(dataBuffer)['message'].toString();
            dataArr.add(message);
          });
        }
      } else {
        var resultRemove = _removeDataToCheck(json.decode(dataBuffer)['round']);
        if (resultRemove == true) {
          setState(() {
            double round =
                double.parse(json.decode(dataBuffer)['round'].toString());
            double numtotal =
                double.parse(json.decode(dataBuffer)['total'].toString());
            percent = round / numtotal;

            message = json.decode(dataBuffer)['message'].toString();
            dataArr.add(message);
          });
        }
      }
      // _convertToImage();
      if (json.decode(dataBuffer)['round'] ==
          json.decode(dataBuffer)['total']) {
        _convertToImage();
      } else {
        print('checkTime');
      }
    } else {
      print("NO");
    }
  }

  Future<void> waitTimeOutToCheck() async {
    timeOut = Timer(Duration(seconds: 5), () {
      print('PrinttimeOut');
      _convertToImage();
    });

    // and later, before the timer goes off...
    // t.cancel();
  }

  void _addDataToCheck(int number) {
    for (var i = 0; i < number; i++) {
      missing.add(i + 1);
    }
  }

  _removeDataToCheck(int number) {
    var result = missing.remove(number);
    return result;
  }

  void _refundData() {
    var dataRefund = {
      'trans': '12345',
      "data": {
        "message": missing,
        "channel": _to.text,
        "type": "IMAGE",
        "total": 1,
        "round": 1,
        "sumData": missing.length,
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
              // timeOut.cancel();
              print(dataArr);
            },
            icon: Icon(Icons.cancel)),
        IconButton(
            onPressed: () {
              print('object');
              waitTimeOutToCheck();
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
                newList.addAll(jsonDecode(dataArr[i]));
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
                  sendMessage();
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
