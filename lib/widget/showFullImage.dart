import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ShowFullImageScreen extends StatefulWidget {
  final String sender;
  final String hour;
  final String minute;
  final String imageAddress;
  const ShowFullImageScreen(
      {super.key,
      required this.imageAddress,
      required this.hour,
      required this.minute,
      required this.sender});

  @override
  State<ShowFullImageScreen> createState() => _ShowFullImageScreenState();
}

class _ShowFullImageScreenState extends State<ShowFullImageScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    convert();
  }

  late Uint8List _bytes;
  void convert() {
    String uri = widget.imageAddress.toString();
    _bytes = base64.decode(uri.split(',').last);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.sender),
                  Text(
                    "${widget.hour}:${widget.minute} ນ",
                    style: TextStyle(fontSize: 13),
                  )
                ],
              ),
            ],
          )),
      body: Center(
          child: InteractiveViewer(
              panEnabled: false,
              boundaryMargin: EdgeInsets.all(100),
              minScale: 0.1,
              maxScale: 10,
              child: Image.memory(_bytes))),
    );
  }
}
