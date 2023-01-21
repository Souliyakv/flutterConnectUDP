import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  final _textController = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _to = TextEditingController();
  int showImage = 0;
  List<Uint8List> sperate = [];
  late Uint8List _bytes;
  List<int> Check = [];
 late RawDatagramSocket socket;
  void login() async {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 2222)
        .then((RawDatagramSocket socket) {
      // Set the handler for receiving data
      this.socket=socket;
        this.socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          // Read the data
          Datagram? dg = this.socket.receive();
          List<int> result = dg!.data;
          data = utf8.decode(result);
          // print('channel is :' + json.decode(data)['channel'].toString());
          // print('type is :' + json.decode(data)['type'].toString());
          // print('total is :' + json.decode(data)['total'].toString());
          // print('round is :' + json.decode(data)['round'].toString());
          if (json.decode(data)['round'] == 1) {
            Check.clear();
            dataArr.clear();
            setState(() {
              message = json.decode(data)['message'].toString();
              dataArr.add(message);
              Check.add(json.decode(data)['round']);
            });
          } else {
            setState(() {
              message = json.decode(data)['message'].toString();
              dataArr.add(message);
              Check.add(json.decode(data)['round']);
            });
          }
          if (json.decode(data)['total'].toString() ==
              json.decode(data)['round'].toString()) {
            if (json.decode(data)['total'] == Check.length) {
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
              });
              print(json.decode(data)['total'].toString());
              print(Check.length);
              print(Check);
            } else {
              print('error');
            }
          }
        }
      });
          var login = {
        "data": {"userName": _username.text, "password": _password.text},
        "command": "login",
      };
      this.socket.send(utf8.encode(jsonEncode(login)),
          InternetAddress('192.168.1.108'), 2222);
      // this.socket.listen((RawSocketEvent event) {
      //   if (event == RawSocketEvent.read) {
      //     // Read the data
      //     Datagram? dg = socket.receive();
      //     print('Received ${dg!.data} from ${dg.address}:${dg.port}');
      //   }
      // });
      // var login = {
      //   "data": {"userName": _username.text, "password": _password.text},
      //   "command": "login",
      // };
      // this.socket.send(utf8.encode(jsonEncode(login)),
      //     InternetAddress('192.168.1.108'), 2222);
    });
    
  }

  void sendMessage() async {
    // int count = 0;
    // RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 2222)
    //     .then((RawDatagramSocket socket) {
      // Set the handler for receiving data
      // this.socket.listen((RawSocketEvent event) {
      //   if (event == RawSocketEvent.read) {
      //     // Read the data
      //     Datagram? dg = this.socket.receive();
      //     List<int> result = dg!.data;
      //     data = utf8.decode(result);
      //     // print('channel is :' + json.decode(data)['channel'].toString());
      //     // print('type is :' + json.decode(data)['type'].toString());
      //     // print('total is :' + json.decode(data)['total'].toString());
      //     // print('round is :' + json.decode(data)['round'].toString());
      //     if (json.decode(data)['round'] == 1) {
      //       Check.clear();
      //       dataArr.clear();
      //       setState(() {
      //         message = json.decode(data)['message'].toString();
      //         dataArr.add(message);
      //         Check.add(json.decode(data)['round']);
      //       });
      //     } else {
      //       setState(() {
      //         message = json.decode(data)['message'].toString();
      //         dataArr.add(message);
      //         Check.add(json.decode(data)['round']);
      //       });
      //     }
      //     if (json.decode(data)['total'].toString() ==
      //         json.decode(data)['round'].toString()) {
      //       if (json.decode(data)['total'] == Check.length) {
      //         List<dynamic> newList = [];

      //         for (int i = 0; i < dataArr.length; i++) {
      //           newList.addAll(jsonDecode(dataArr[i]));
      //         }
      //         setState(() {
      //           String base64string = base64.encode(newList.cast<int>());
      //           imageFireResult = "data:image/jpg;base64,$base64string";
      //           String uri = imageFireResult.toString();
      //           _bytes = base64.decode(uri.split(',').last);
      //           _testText.text = imageFireResult;
      //           showImage = 1;
      //         });
      //         print(json.decode(data)['total'].toString());
      //         print(Check.length);
      //         print(Check);
      //       } else {
      //         print('error');
      //       }
      //     }
      //   }
      // });
print('object');
      Timer.periodic(new Duration(milliseconds: 200), (timer) {
        int index = int.parse(timer.tick.toString());
        index = index - 1;
        if (index < sperate.length) {
          var data = {
            'trans':'12345',
            "data": {
              "message": sperate[index],
              "channel": _to.text,
              "type": "IMAGE",
              "total": sperate.length,
              "round": index + 1,
              "sumData": ''
            },
            "token": _username.text,
            "command": "send"
          };
          print(this.socket);
          this.socket.send(utf8.encode(jsonEncode(data)),
              InternetAddress('192.168.1.108'), 2222);
           print('hello' + timer.tick.toString());
        } else {
          sperate = [];
          timer.cancel();
        }
      });
    // });
  }

  Future chooseImage(BuildContext context) async {
    try {
      var image = await ImagePicker().getImage(source: ImageSource.gallery);
      file = File(image!.path);
      imagebytes = await file!.readAsBytes();

      int chunkSize = 2500;
      for (int i = 0; i < imagebytes.length; i += chunkSize) {
        int end = i + chunkSize < imagebytes.length
            ? i + chunkSize
            : imagebytes.length;
        // chunk.add(imagebytes.sublist(i, end));
        sperate.add(imagebytes.sublist(i, end));
      }
      _testText.text = sperate.length.toString();
      print(file);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
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
              ? Text("ບໍ່ມີຮູບພາບ")
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
                  sendMessage();
                }
              },
              child: Text("send"))
        ]),
      ),
    );
  }
}
