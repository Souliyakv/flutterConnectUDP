import 'dart:io';
import 'package:demoudp/providers/imageProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CheckVideoScreen extends StatefulWidget {
  final String sender;
  final String channel;
  final videoAddress;
  const CheckVideoScreen(
      {super.key,
      required this.videoAddress,
      required this.channel,
      required this.sender});

  @override
  State<CheckVideoScreen> createState() => _CheckVideoScreenState();
}

class _CheckVideoScreenState extends State<CheckVideoScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late double _deviceHeight;
  late int playvalue;
  late int minutes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    palyVideo();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void palyVideo() async {
    File file = File(widget.videoAddress.toString());

    _controller = VideoPlayerController.file(file);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false);
    _controller.pause();
    minutes = _controller.value.duration.inMinutes;
    _controller.addListener(() {
      setState(() {
        playvalue = int.parse(_controller.value.position.inSeconds.toString());
      });
    });
  }

  // String _showDuration(Duration duration){
  //   String
  // }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar:
          AppBar(backgroundColor: Colors.black, title: const Text('ວິດີໂອ')),
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: _deviceHeight * 0.75,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(alignment: Alignment.center, children: [
                          VideoPlayer(_controller),
                          _controller.value.isPlaying
                              ? const Text("")
                              : const Icon(
                                  Icons.play_arrow,
                                  size: 60,
                                  color: Colors.white,
                                )
                        ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          backgroundColor: Colors.white,
                          playedColor: Color.fromARGB(255, 4, 59, 33),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        playvalue >= 3600
                            ? Text(
                                "   ${playvalue ~/ 3600}:${playvalue ~/ 60}:${playvalue % 60}",
                                style: const TextStyle(color: Colors.white),
                              )
                            : Text(
                                "   ${playvalue ~/ 60}:${playvalue % 60}",
                                style: const TextStyle(color: Colors.white),
                              ),
                        _controller.value.duration.inSeconds >= 3600
                            ? Text(
                                "${_controller.value.duration.inSeconds ~/ 3600}:${_controller.value.duration.inSeconds ~/ 60}:${_controller.value.duration.inSeconds % 60}   ",
                                style: const TextStyle(color: Colors.white),
                              )
                            : Text(
                                "${_controller.value.duration.inSeconds ~/ 60}:${_controller.value.duration.inSeconds % 60}   ",
                                style: const TextStyle(color: Colors.white),
                              )
                      ],
                    )
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var provider =
              Provider.of<ChooseImageProvider>(context, listen: false);
          provider.chooseVideo(
              context, widget.videoAddress, widget.sender, widget.channel);
          Navigator.pop(context);
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}
