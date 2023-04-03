import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:flutter_voice_processor/flutter_voice_processor.dart';

class TestAudio extends StatefulWidget {
  @override
  _TestAudioState createState() => _TestAudioState();
}

class _TestAudioState extends State<TestAudio> {
  VoiceProcessor? _voiceProcessor;
  Function? _removeListener;
  Function? _errorListener;
  FlutterSoundPlayer _soundPlayer = FlutterSoundPlayer();

  @override
  void initState() {
    super.initState();
    _initVoiceProcessor();
  }

  void _initVoiceProcessor() async {
    _voiceProcessor = VoiceProcessor.getVoiceProcessor(64, 16000);
  }

  Future<void> _startProcessing() async {
    _removeListener = _voiceProcessor?.addListener(_onBufferReceived);
    _errorListener = _voiceProcessor?.addErrorListener(_onErrorReceived);
    await _soundPlayer.openPlayer(enableVoiceProcessing: true);
    await _soundPlayer.startPlayerFromStream(
        codec: Codec.pcm16, numChannels: 1, sampleRate: 16000);
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

  void _onBufferReceived(dynamic eventData) async {
    print("Listener 1 received buffer of size ${eventData}!");
    await _soundPlayer
        .feedFromStream(Uint8List.fromList(eventData.cast<int>()));
  }

  void _onErrorReceived(dynamic eventData) {
    String errorMsg = eventData as String;
    print(errorMsg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Processor'),
      ),
      body: Center(
        child: _buildToggleProcessingButton(),
      ),
    );
  }

  Widget _buildToggleProcessingButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            _startProcessing();
          },
          child: Text("Start", style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
            onPressed: () {
              _voiceProcessor!.stop();
              _soundPlayer.stopPlayer();
            },
            child: Text("Stop"))
      ],
    );
  }
}
