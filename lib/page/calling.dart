import 'dart:async';
import 'package:demoudp/model/callingModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/connectSocketUDP_provider.dart';
import '../providers/streamAudioProvider.dart';

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
  FlutterAudioCapture _plugin = new FlutterAudioCapture();
  final player = AudioPlayer();
  int chunkSize = 2205;
  String recordingTime = '';
  late List<int> byte = [];
  bool isRecode = true;
  FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  late Stream<Uint8List> _audioStream;

  @override
  void initState() {
    super.initState();
    // _startCapture();
    _startCapture();
    // player.setAudioSource(MyCustomSource(byte));
    // player.play();
    // recordTime();
  }

  void dispose() {
    _plugin.stop();
    super.dispose();
  }

  Future<void> _startCapture() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw "Microphone permission not granted";
    }
    print('start');
    await _plugin.start(listener, onError, sampleRate: 16000, bufferSize: 3000);
    var pvdStream = Provider.of<StreamAudioProvider>(context, listen: false);
    pvdStream.startStream();
  }

  Future<void> stopCapture() async {
    Navigator.pop(context);
    await _plugin.stop();
    Navigator.pop(context);
  }

  void listener(dynamic obj) {
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);

    var buffer = Float64List.fromList(obj.cast<double>());
    // List<Float64List> sperate = [];
    // for (var i = 0; i < buffer.length; i++) {
    //   int end = i + 2205 < buffer.length ? i + 2202 : buffer.length;
    //   sperate.add(buffer.sublist(i, end));
    // }'
    AppCallingModel appCallingModel = AppCallingModel(
        address: widget.address, message: buffer, port: widget.port);
    pvdConnect.appCalling(appCallingModel);
    // AppCallingModel appCallingModel = AppCallingModel(
    //     address: widget.address, message: buffer, port: widget.port);
    // pvdConnect.appCalling(appCallingModel);
  }

  void onError(Object e) {
    print(e);
  }

//   Future<void> startRecording() async {
//     PermissionStatus status = await Permission.microphone.request();
//     if (status != PermissionStatus.granted)
//             throw RecordingPermissionException("Microphone permission not granted");

//   // await _soundRecorder.openAudioSession();
//   await _soundRecorder.startRecorder(toStream: true,);
//   _audioStream = _soundRecorder.
//   _audioStream = _soundRecorder.onRecorderStateChanged.map(
//     (e) => e.buffer.asUint8List(e.buffer.lengthInBytes),
//   );
// }

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
                  '${widget.channel}',
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
                    var pvdConnect = Provider.of<ConnectSocketUDPProvider>(
                        context,
                        listen: false);
                    HangUpCallModel hangUpCallModel = HangUpCallModel(
                        address: widget.address, port: widget.port);
                    pvdConnect.hangUpCall(hangUpCallModel);
                    stopCapture();
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
