import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class RoundedChatMessage extends StatelessWidget {
  final String message;
  final String hour;
  final String minute;
  const RoundedChatMessage(
      {super.key,
      required this.message,
      required this.hour,
      required this.minute});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 204, 240, 205),
          borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.all(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
              onLongPress: () {
                Clipboard.setData(new ClipboardData(text: message.toString()));
              },
              child: Text(message)),
          Text(
            '${hour}:${minute} ນ',
            style: TextStyle(fontSize: 10),
          )
        ],
      ),
    );
  }
}

class RoundedChatImage extends StatelessWidget {
  final void Function()? onTap;
  final Uint8List bytes;
  final String hour;
  final String minute;
  const RoundedChatImage(
      {super.key,
      required this.onTap,
      required this.bytes,
      required this.hour,
      required this.minute});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 204, 240, 205),
          borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.all(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: MemoryImage(bytes), fit: BoxFit.cover)),
            ),
          ),
          Text(
            '${hour}:${minute} ນ',
            style: TextStyle(fontSize: 10),
          )
        ],
      ),
    );
  }
}

class RoundedChatVideo extends StatelessWidget {
  final void Function()? onTap;
  final String hour;
  final String minute;
  final VideoPlayerController controller;
  const RoundedChatVideo(
      {super.key,
      required this.onTap,
      required this.hour,
      required this.minute,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 204, 240, 205),
          borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.all(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 180,
              width: 180,
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Stack(alignment: Alignment.center, children: [
                  VideoPlayer(controller),
                  const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  )
                ]),
              ),
            ),
          ),
          Text(
            '${hour}:${minute} ນ',
            style: TextStyle(fontSize: 10),
          )
        ],
      ),
    );
  }
}
