import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayVideoScreen extends StatefulWidget {
  final String sender;
  final String hour;
  final String minute;
  final videoAddress;
  const PlayVideoScreen(
      {super.key,
      required this.hour,
      required this.minute,
      required this.sender,
      required this.videoAddress});

  @override
  State<PlayVideoScreen> createState() => _PlayVideoScreenState();
}

class _PlayVideoScreenState extends State<PlayVideoScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    palyVideo();
  }

  void palyVideo() async {
    File file = File(widget.videoAddress.toString());

    _controller = VideoPlayerController.file(file);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false);
    _controller.play();
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
                child: Container(padding: EdgeInsets.all(5),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(alignment: Alignment.center, children: [
                      VideoPlayer(_controller),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: Icon(_controller.value.isPlaying
                      //       ? Icons.pause
                      //       : Icons.play_arrow),
                      // ),
                      _controller.value.isPlaying
                          ? const Text("")
                          : const Icon(
                              Icons.play_arrow,
                              size: 50,
                            )
                    ]),
                  ),
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
    );
  }
}
