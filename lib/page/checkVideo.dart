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
    _controller.pause();
  }

  @override
  Widget build(BuildContext context) {
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
