import 'dart:async';
import 'package:demoudp/model/callingModel.dart';
import 'package:demoudp/providers/call_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectSocketUDP_provider.dart';

class Calling extends StatefulWidget {
  final String channel;
  final String sender;
  final String address;
  final port;
  const Calling(
      {super.key,
      required this.address,
      required this.channel,
      required this.port,
      required this.sender});

  @override
  State<Calling> createState() => _CallingState();
}

class _CallingState extends State<Calling> {
  String recordingTime = '';
  bool isRecode = true;

  void recordTime() {
    int startTime = 0;
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        startTime = startTime + 1;
        recordingTime = '${startTime ~/ 60}:${startTime % 60}';
      });
      if (!isRecode) {
        t.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 4, 59, 33),
      backgroundColor: Colors.green,
      appBar: AppBar(
          // backgroundColor: Color.fromARGB(255, 4, 59, 33),
          backgroundColor: Colors.green,
          title: const Text("Ent to end encrypted")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 80,
            child: Column(
              children: [
                Text(
                  'a',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                Text(
                  '${recordingTime}',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              ],
            ),
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 420,
                width: double.infinity,
                color: Colors.blueGrey,
                child: const Icon(
                  Icons.person,
                  size: 300,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    var pvdCallStream =
                        Provider.of<CallProvider>(context, listen: false);
                    var pvdConnect = Provider.of<ConnectSocketUDPProvider>(
                        context,
                        listen: false);
                    HangUpCallModel hangUpCallModel = HangUpCallModel(
                        address: widget.address, port: widget.port);
                    pvdConnect.hangUpCall(hangUpCallModel);
                    pvdCallStream.stopRecorder();
                    // pvdCallStream.play();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.call_end),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.video_call,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.mic_external_off,
                      color: Colors.white,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}

// class MyCustomSource extends StreamAudioSource {
//   final List<int> bytes;
//   MyCustomSource(this.bytes);

//   @override
//   Future<StreamAudioResponse> request([int? start, int? end]) async {
//     start ??= 0;
//     end ??= bytes.length;
//     return StreamAudioResponse(
//         sourceLength: bytes.length,
//         contentLength: end - start,
//         offset: start,
//         stream: Stream.value(bytes.sublist(start, end)),
//         contentType: 'audio/mpeg');
//   }
// }
