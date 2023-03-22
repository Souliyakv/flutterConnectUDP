import 'dart:async';
import 'package:demoudp/model/callingModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_voice_processor/flutter_voice_processor.dart';
import 'package:just_audio/just_audio.dart';
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
  final player = AudioPlayer();
  int chunkSize = 2205;
  String recordingTime = '';
  late List<int> byte = [];
  bool isRecode = true;
  VoiceProcessor? _voiceProcessor;
  Function? _removeListener;
  Function? _errorListener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initVoiceProcessor();
  }

  void _initVoiceProcessor() async {
    _voiceProcessor = VoiceProcessor.getVoiceProcessor(512, 16000);
    _startProcessing();
  }

  void dispose() {
    _voiceProcessor!.stop();
    super.dispose();
  }

  Future<void> _startProcessing() async {
    _removeListener = _voiceProcessor?.addListener(_onBufferReceived);
    _errorListener = _voiceProcessor?.addErrorListener(_onErrorReceived);
    try {
      if (await _voiceProcessor?.hasRecordAudioPermission() ?? false) {
        await _voiceProcessor?.start();
      } else {
        print("Recording permission not granted");
      }
    } on PlatformException catch (ex) {
      print("Failed to start recorder: " + ex.toString());
    } finally {}
  }

  void _onBufferReceived(dynamic eventData) {
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    // print("Listener 1 received buffer of size ${eventData}!");
    AppCallingModel appCallingModel = AppCallingModel(
        address: widget.address, message: eventData, port: widget.port);
    pvdConnect.appCalling(appCallingModel);
  }

  void _onErrorReceived(dynamic eventData) {
    String errorMsg = eventData as String;
    print(errorMsg);
  }

  void listener(dynamic obj) {
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);

    var buffer = Float64List.fromList(obj.cast<double>());
    // List<Float64List> sperate = [];
    // for (var i = 0; i < buffer.length; i++) {
    //   int end = i + 200 < buffer.length ? i + 200 : buffer.length;
    // sperate.add(buffer.sublist(i, end));
    AppCallingModel appCallingModel = AppCallingModel(
        address: widget.address,
        message: buffer.sublist(0, 500),
        port: widget.port);
    pvdConnect.appCalling(appCallingModel);
    // }

    // AppCallingModel appCallingModel = AppCallingModel(
    //     address: widget.address, message: buffer, port: widget.port);
    // pvdConnect.appCalling(appCallingModel);
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
