import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Socket _socket;
  late Socket socket;

  String _data = '';
  final _textController = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _to = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createScoket();
  }

  void _send() {
    if (_textController.text.isNotEmpty) {
      // _socket.write(jsonEncode({"msg": _textController.text}));
      var data = {
        "data": {"message": _textController.text, "channel": _to.text},
        "token": _username.text,
        "command": "send"
      };
      socket.add(utf8.encode(jsonEncode(data)));
      _textController.clear();
    }
  }

  void _login() {
    if (_username.text.isNotEmpty) {
      // _socket.write(jsonEncode({"msg": _textController.text}));

      var login = {
        "data": {"userName": _username.text, "password": _password.text},
        "command": "login"
      };
      socket.add(utf8.encode(jsonEncode(login)));
      _textController.clear();
    }
  }

  void createScoket() async {
    Socket.connect('192.168.0.131', 8980).then((Socket sock) {
      socket = sock;
      socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
    }).catchError((AsyncError e) {
      print("Unable to connect: $e");
    });
    stdin.listen((data) {
      var test = socket.write(new String.fromCharCodes(data).trim() + '\n');
    });
  }

  void dataHandler(data) {
    final serverResponse = String.fromCharCodes(data);
    setState(() {
      _data = json.decode(serverResponse)['message'];
    });
    print(serverResponse);
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    socket.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TEST"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.refresh))],
      ),
      body: Column(children: [
        Expanded(
            child: SingleChildScrollView(
          child: Text(_data),
        )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _username,
            decoration: InputDecoration(hintText: "ຜຸ້ສົ່ງ"),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _password,
            decoration: InputDecoration(hintText: "ລະຫັດຜ່ານ"),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _to,
            decoration: InputDecoration(hintText: "ຜຸ້ຮັບ"),
          ),
        ),
        SizedBox(
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
              _login();
            },
            child: Text("LOGIN")),
        TextButton(
            onPressed: () {
              _send();
            },
            child: Text("send"))
      ]),
    );
  }
}
