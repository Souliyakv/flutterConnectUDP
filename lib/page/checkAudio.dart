import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class CheckAudioScreen extends StatefulWidget {
  final String sender;
  final String channel;
  final audioAddress;
  const CheckAudioScreen(
      {super.key,
      required this.audioAddress,
      required this.channel,
      required this.sender});

  @override
  State<CheckAudioScreen> createState() => _CheckAudioScreenState();
}

class _CheckAudioScreenState extends State<CheckAudioScreen> {
  bool _play = true;
  double position = 0.0;
  double durationData = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("ສຽງ"),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 300,
              width: double.infinity,
              // decoration: const BoxDecoration(
              //     image: DecorationImage(
              //   image: AssetImage("assets/image/audio.jpeg"),
              //   fit: BoxFit.cover,
              // )),
              child:
                  const Icon(Icons.music_video, color: Colors.white, size: 350),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "${widget.audioAddress}",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${position.toInt() ~/ 60}:${position.toInt() % 60}',
                style: const TextStyle(color: Colors.white),
              ),
              Slider(
                min: 0.0,
                max: durationData,
                value: position,
                onChanged: (value) {
                  setState(() {
                    position = value;
                  });
                },
              ),
              Text(
                '${durationData.toInt() ~/ 60}:${durationData.toInt() % 60}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Center(
            child: AudioWidget.file(
              onFinished: () {
                setState(() {
                  _play = false;
                });
              },
              path: widget.audioAddress,
              play: _play,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    _play = !_play;
                  });
                },
                child: Icon(
                  _play ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                  size: 50,
                ),
              ),
              onPositionChanged: (current, duration) {
                setState(() {
                  position = current.inSeconds.toDouble();
                  durationData = duration.inSeconds.toDouble();
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(
          Icons.send,
          color: Colors.black,
        ),
      ),
    );
  }
}
