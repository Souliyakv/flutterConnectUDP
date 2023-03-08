import 'dart:async';
import 'dart:io';
import 'package:demoudp/providers/imageProvider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record_mp3/record_mp3.dart';

class RecodeAudioScreen extends StatefulWidget {
  final String sender;
  final String channel;
  const RecodeAudioScreen(
      {super.key, required this.channel, required this.sender});

  @override
  State<RecodeAudioScreen> createState() => _RecodeAudioScreenState();
}

class _RecodeAudioScreenState extends State<RecodeAudioScreen> {
  String statusText = "";
  bool isComplete = false;
  bool isRecode = true;
  String recordingTime = '00:00';
  late int longTime;

  @override
  void initState() {
    super.initState();
    startRecord();
    recordTime();
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      statusText = "Recording...";
      recordFilePath = await getFilePath();
      isComplete = false;
      RecordMp3.instance.start(recordFilePath, (type) {
        statusText = "Record error--->$type";
        setState(() {});
      });
    } else {
      statusText = "No microphone permission";
    }
    setState(() {});
  }

  void stopRecord() {
    bool s = RecordMp3.instance.stop();
    if (s) {
      statusText = "Record complete";
      isComplete = true;
      setState(() {});
    }
    var provider = Provider.of<ChooseImageProvider>(context, listen: false);
    provider.chooseAudio(
        context, recordFilePath, widget.sender, widget.channel, longTime);
    Navigator.pop(context);
  }

  // void resumeRecord() {
  //   bool s = RecordMp3.instance.resume();
  //   if (s) {
  //     statusText = "Recording...";
  //     setState(() {});
  //   }
  // }

  late String recordFilePath;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/${DateTime.now().millisecondsSinceEpoch.toString()}.mp3";
  }

  void recordTime() {
    int startTime = 0;
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (startTime >= 600) {
        stopRecord();
        t.cancel();
      } else {
        setState(() {
          startTime = startTime + 1;
          recordingTime = '${startTime ~/ 60}:${startTime % 60}';
          longTime = startTime - 1;
        });
        if (!isRecode) {
          t.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$recordingTime',
                style: const TextStyle(color: Colors.white, fontSize: 50),
              ),
              const SizedBox(
                height: 25,
              ),
              FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    isRecode = !isRecode;
                  });
                  stopRecord();
                },
                child: Icon(
                  isRecode ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                  size: 50,
                ),
              )
            ],
          ),
        ));
  }
}
