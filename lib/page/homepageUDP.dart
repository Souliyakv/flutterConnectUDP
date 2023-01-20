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
  var allBuffer;
  late String base64Image = '';
  String data = '';
  late String message;
  List<String> dataArr = [];

  final _textController = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _to = TextEditingController();
  List<List<int>> chunk = <List<int>>[];
  int temp = 0;
  XFile? _image;
  var arrayBuffer;
  int showImage = 0;

  List<dynamic> test = [];
  List<int> myList = [];
  List<String> tetsData = [];
  List<Uint8List> sperate = [];
  List<int> sperateList = [];
  late Uint8List _bytes;

  List<int> arr = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void login() async {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 2222)
        .then((RawDatagramSocket socket) {
      // Set the handler for receiving data
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          // Read the data
          Datagram? dg = socket.receive();
          print('Received ${dg!.data} from ${dg.address}:${dg.port}');
        }
      });
      var login = {
        "data": {"userName": _username.text, "password": _password.text},
        "command": "login",
      };
      // var login = '{"data":{"userName":"a","password": "a"},"command":""login}';
      // Send a UDP packet
      socket.send(utf8.encode(jsonEncode(login)),
          InternetAddress('192.168.0.131'), 2222);
    });
  }

  void sendMessage() async {
    int count = 0;
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 2222)
        .then((RawDatagramSocket socket) {
      // Set the handler for receiving data
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          // Read the data
          Datagram? dg = socket.receive();
          List<int> result = dg!.data;
          data = utf8.decode(result);
          // print('channel is :' + json.decode(data)['channel'].toString());
          // print('type is :' + json.decode(data)['type'].toString());
          // print('total is :' + json.decode(data)['total'].toString());
          // print('round is :' + json.decode(data)['round'].toString());
          if (json.decode(data)['round'] == 1) {
            dataArr.clear();
            setState(() {
              message = json.decode(data)['message'].toString();
              dataArr.add(message);
            });
          } else {
            setState(() {
              message = json.decode(data)['message'].toString();

              // data = utf8.decode(result);
              // String a = message.split(' ')[0];

              dataArr.add(message);
            });
          }
          if (json.decode(data)['total'].toString() ==
              json.decode(data)['round'].toString()) {
            List<dynamic> newList = [];
            var a = [];

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
          }
        }
      });

      Timer.periodic(new Duration(milliseconds: 200), (timer) {
        int index = int.parse(timer.tick.toString());
        index = index - 1;
        print('left' +
            index.toString() +
            ' right' +
            (index).toString() +
            'all' +
            sperate.length.toString());
        // print(sperate[index].toString());
        if (index < sperate.length) {
          var data = {
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
          socket.send(utf8.encode(jsonEncode(data)),
              InternetAddress('192.168.0.131'), 2222);
          // print('hello' + timer.tick.toString());
        } else {
          sperate = [];
          timer.cancel();
        }
      });
      // for (var i = 0; i < sperate.length; i++) {
      //   var data = {
      //     "data": {
      //       "message": sperate[i],
      //       "channel": _to.text,
      //       "type": i,
      //       "total": sperate.length,
      //       "round": i,
      //       "sumData": ''
      //     },
      //     "token": _username.text,
      //     "command": "send"
      //   };
      //   socket.send(utf8.encode(jsonEncode(data)),
      //       InternetAddress('192.168.0.131'), 2222);
      // }

      // _testText.text = sperate.toString();
      // print(sperate);

      // for (int i = 0; i < sperate.length; i++) {
      //   print(sperate[i]);
      //   var data = {
      //     "data": {
      //       "message": sperate[i],
      //       "channel": _to.text,
      //       "type": "IMAGE",
      //       "total": sperate.length,
      //       "round": i,
      //       "sumData": ''
      //     },
      //     "token": _username.text,
      //     "command": "send"
      //   };

      //   socket.send(utf8.encode(jsonEncode(data)),
      //       InternetAddress('192.168.0.131'), 2222);
      // }

      // Timer.periodic(new Duration(seconds: 1), (timer) {
      //   // print('hello world! ' + timer.tick.toString());
      // });
      // print(sperate);

      // _testText.text = sperate.toString();

      // print(chunk.length);
      // Timer.periodic(new Duration(seconds: 1), (timer) {
      //   // print('hello world! ' + timer.tick.toString());
      // });

      // const trans = '123456';
      // for (var i = 0; i < chunk.length; i++) {
      //   var data = {
      //     "data": {
      //       "message": chunk[i],
      //       "channel": _to.text,
      //       "type": "IMAGE",
      //       "total": chunk.length,
      //       "round": i,
      //       "sumData": ''
      //     },
      //     "token": _username.text,
      //     "command": "send"
      //   };

      // var login = '{"data":{"userName":"a","password": "a"},"command":""login}';
      // Send a UDP packet
      // socket.send(utf8.encode(jsonEncode(data)),
      // InternetAddress('192.168.0.131'), 2222);
      // }
    });
  }

  // Future chooseImage(BuildContext context) async {
  //   try {
  //     var image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //     setState(() {
  //       _image = image;
  //     });
  //     int chunkSize = 10000;
  //     var result = await _image!.readAsBytes();
  //     allBuffer = result;
  //     chunk.clear();
  //     for (int i = 0; i < result.length; i += chunkSize) {
  //       int end = i + chunkSize < result.length ? i + chunkSize : result.length;
  //       chunk.add(result.sublist(i, end));
  //     }
  //   } catch (e) {
  //     print('error is ' + e.toString());
  //   }
  // }

  Future chooseImage(BuildContext context) async {
    try {
      var image = await ImagePicker().getImage(source: ImageSource.gallery);
      file = File(image!.path);
      imagebytes = await file!.readAsBytes();
      int chunkSize = 10000;
      for (int i = 0; i < imagebytes.length; i += chunkSize) {
        int end = i + chunkSize < imagebytes.length
            ? i + chunkSize
            : imagebytes.length;
        // chunk.add(imagebytes.sublist(i, end));
        sperate.add(imagebytes.sublist(i, end));
      }
      _testText.text = sperate.length.toString();
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
          // TextFormField(
          //   initialValue: base64Image,
          // ),
          // Expanded
          //     child: SingleChildScrollView(
          //   child: Text(_data),
          // )),
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
