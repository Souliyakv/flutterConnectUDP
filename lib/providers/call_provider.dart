import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../model/callingModel.dart';

class CallProvider with ChangeNotifier {
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  StreamSubscription? _mRecordingDataSubscription;
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  var dataToPlay = [];
  var allData = [];
  late int startT;

  initData() {
    _mPlayer.openPlayer();
    openRecorder();
  }

  disposeData() {
    stopPlayer();
    _mPlayer.closePlayer();

    stopRecorder();
    _mRecorder.closeRecorder();
  }

  openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Microphone permission not granted");
    }
    await _mRecorder.openRecorder();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    // record(context, address, port);
  }

  record(BuildContext context, String address, int port) async {
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    // print("Listener 1 received buffer of size ${eventData}!");

    dataToPlay = [];
    // assert(_mRecorderIsInited && _mPlayer.isStopped);
    var recordingDataController = StreamController<Food>();
    _mRecordingDataSubscription =
        recordingDataController.stream.listen((buffer) {
      if (buffer is FoodData) {
        AppCallingModel appCallingModel =
            AppCallingModel(address: address, message: buffer.data, port: port);
        pvdConnect.appCalling(appCallingModel);
      }
    });
    await _mRecorder.startRecorder(
        toStream: recordingDataController.sink,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: 44000);
    // testTime();
    startT = DateTime.now().microsecondsSinceEpoch;

    play([]);
  }

  stopRecorder() async {
    await _mRecorder.stopRecorder();
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }
    _mplaybackReady = true;
    // play();
  }

  testTime() {
    Timer.periodic(const Duration(milliseconds: 750), (Timer ti) {
      // play();
      dataToPlay = [];
    });
  }

  play(List<dynamic> d) async {
    if (d.length > 0) dataToPlay.add(d);
    // print("length is :${dataToPlay.length}");
    // assert(_mPlayerIsInited &&
    //     _mplaybackReady &&
    //     _mRecorder.isStopped &&
    //     _mPlayer.isStopped);
    if (dataToPlay.length > 0) {
      await _mPlayer.startPlayer(
          fromDataBuffer: Uint8List.fromList(dataToPlay[0].cast<int>()),
          sampleRate: 44000,
          codec: Codec.pcm16,
          numChannels: 1,
          whenFinished: () {
            // dataToPlay = allData;
            // dataToPlay.add(allData.cast<int>());
            // allData = [];
            // startT = DateTime.now().microsecondsSinceEpoch;
            dataToPlay.removeAt(0);
            play([]);
            // print("Length is :${dataToPlay.length}");
            // dataToPlay = [];
          });
    }
    // _mPlayer.stopPlayer();
  }

  getBuffer(var buffer) {
    // dataToPlay.addAll(buffer.cast<int>());
    // print("Buffer is :${buffer.length}");
    // print("Buffer is :${buffer}");
    if (DateTime.now().microsecondsSinceEpoch - startT > 1200000) {
      allData.addAll(buffer.cast<int>());
      play(allData);
      allData.clear();
      startT = DateTime.now().microsecondsSinceEpoch;
    } else {
      allData.addAll(buffer.cast<int>());
    }
  }

  Future<void> stopPlayer() async {
    await _mPlayer.stopPlayer();
  }
}
