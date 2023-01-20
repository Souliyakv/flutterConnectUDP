import 'dart:io';

import 'package:flutter/material.dart';
import 'package:udp/udp.dart';

class HomeScreenUDP extends StatefulWidget {
  const HomeScreenUDP({super.key});

  @override
  State<HomeScreenUDP> createState() => _HomeScreenUDPState();
}

class _HomeScreenUDPState extends State<HomeScreenUDP> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    udp();
  }

  udp() async {
    // var sender = await UDP.bind(Endpoint.any(port: Port(2222)));
    // print(sender);
    // var dataLength = await sender.send(
    //     "hello Souliya".codeUnits, Endpoint.broadcast(port: Port(2222)));
    // print(dataLength);

    // stdout.write("$dataLength bytes sent.");
    // var receiver = await UDP.bind(Endpoint.loopback(port: Port(2222)));
    // receiver.asStream(timeout: Duration(seconds: 20)).listen((event) {
    //   var str = String.fromCharCodes(event!.data);
    //   stdout.write(str);
    // });
    // print(receiver);
    // sender.close();
    // receiver.close();

    var multiccaseEnpoint =
        Endpoint.multicast(InternetAddress('192.168.0.131'), port: Port(2222));
    print(multiccaseEnpoint);
    var receiver = await UDP.bind(multiccaseEnpoint);
    var sender = await UDP.bind(Endpoint.any());
    receiver.asStream().listen((event) {
      if (event != null) {
        print('Not Null');
        var str = String.fromCharCodes(event.data);
        stdout.write(str);
      }
      print('Null');
    });
    await sender.send("data".codeUnits, multiccaseEnpoint);
    await Future.delayed(Duration(seconds: 5));
    sender.close();
    receiver.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
        centerTitle: true,
      ),
    );
  }
}
