import 'dart:convert';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:demoudp/model/imageModel.dart';
import 'package:demoudp/model/textMessage_model.dart';
import 'package:demoudp/model/typingStatusModel.dart';
import 'package:demoudp/page/callingPage.dart';
import 'package:demoudp/page/cameraPage.dart';
import 'package:demoudp/page/checkAudio.dart';
import 'package:demoudp/page/checkVideo.dart';
import 'package:demoudp/page/playVideo.dart';
import 'package:demoudp/page/recodeAudio.dart';
import 'package:demoudp/providers/call_provider.dart';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:demoudp/providers/imageProvider.dart';
import 'package:demoudp/providers/statusTypingProvider.dart';
import 'package:demoudp/providers/textMessage_provider.dart';
import 'package:demoudp/widget/customAttack.dart';
import 'package:demoudp/widget/showAlert.dart';
import 'package:demoudp/widget/showFullImage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../widget/roundedChatpage.dart';

class ChatPage extends StatefulWidget {
  final String username;
  final String password;
  final String channel;
  const ChatPage(
      {super.key,
      required this.username,
      required this.password,
      required this.channel});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String paths = '';
  final assetsAudioPlayer = AssetsAudioPlayer();
  String playIndex = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode.addListener(_onFocusChange);
    setState(() {
      _username = widget.username;
      _password = widget.password;
      _to = widget.channel;
    });
    var pvdImage = Provider.of<ChooseImageProvider>(context, listen: false);
    pvdImage.clearImage();
    // login();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  FocusNode _focusNode = FocusNode();

  void _onFocusChange() {
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    if (_focusNode.hasFocus) {
      SendTypingStatusModel sendstatus =
          SendTypingStatusModel(status: true, channel: _to, token: _username);
      pvdConnect.sendstatusTyping(sendstatus);
      setState(() {
        sendImage = false;
      });
    } else {
      SendTypingStatusModel sendstatus =
          SendTypingStatusModel(status: false, channel: _to, token: _username);
      pvdConnect.sendstatusTyping(sendstatus);
      setState(() {
        sendImage = true;
      });
    }
  }

  bool sendImage = false;

  final txtMessage = TextEditingController();
  late String _username;
  late String _password;
  late String _to;
  File? file;
  // bool _play = false;
  double position = 0.0;
  double durationData = 350;

  void sendtxtMessage() {
    TextMessageModel textMessageModel = TextMessageModel(
        message: txtMessage.text,
        sender: _username,
        hour: DateTime.now().hour.toString(),
        minute: DateTime.now().minute.toString(),
        channel: _to,
        type: "TEXT",
        long: 1);
    var provider = Provider.of<TextMessageProvider>(context, listen: false);
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    provider.addTextMessage(textMessageModel);
    SendTextMessageModel sendtxtData = SendTextMessageModel(
        message: txtMessage.text,
        channel: _to,
        sender: _username,
        hour: DateTime.now().hour.toString(),
        minute: DateTime.now().minute.toString(),
        token: _username);
    pvdConnect.sendtxtMessage(sendtxtData);
    txtMessage.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 129, 149, 158),
        appBar: AppBar(
          leading: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back)),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                        image: NetworkImage(
                            "https://www.apple.com/v/siri/f/images/meta/siri__fsb5b98qe526_og.png?202207261927"),
                        fit: BoxFit.cover)),
              ),
            ],
          ),
          backgroundColor: Color.fromARGB(255, 4, 59, 33),
          title: Row(
            children: [
              Consumer(
                builder: (context, StatusTypingProvider statusTypingProvider,
                    child) {
                  // bool typing = statusTypingProvider.typingStatus[_to];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_to}",
                        style: TextStyle(fontSize: 18),
                      ),
                      // typing == true
                      //     ? const Text(
                      //         "ກຳລັງພິມ...",
                      //         style: TextStyle(fontSize: 12),
                      //       )
                      //     : const
                      const Text(
                        "ອອນລາຍ",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            Consumer(
              builder:
                  (context, ChooseImageProvider chooseImageProvider, child) {
                var checkImage = chooseImageProvider.allImageToSendKey;
                return IconButton(
                    onPressed: () {
                      if (checkImage.length <= 0) {
                        ShowAlert.showAlert(context, 'ກະລຸນາເລືອກຮູບພາບ');
                      }
                      var pvdConnect = Provider.of<ConnectSocketUDPProvider>(
                          context,
                          listen: false);
                      SendImageModel sendImageModel =
                          SendImageModel(token: _username, channel: _to);
                      pvdConnect.sendImage(sendImageModel, context, 'IMAGE');
                    },
                    icon: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        const Icon(Icons.send_time_extension),
                        Text(
                          "${checkImage.length}",
                          style: TextStyle(color: Colors.red),
                        )
                      ],
                    ));
              },
            ),
            IconButton(
                onPressed: () {
                  // checkVideo();
                  var pvdCallStream =
                      Provider.of<CallProvider>(context, listen: false);
                  pvdCallStream.play([]);
                },
                icon: const Icon(Icons.video_camera_back)),
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return RecodeAudioScreen(
                      sender: _username,
                      channel: _to,
                    );
                  }));
                },
                icon: const Icon(Icons.record_voice_over_sharp)),
            IconButton(
                onPressed: () {
                  var pvdCallStream =
                      Provider.of<CallProvider>(context, listen: false);
                  pvdCallStream.initData();
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return CallingScreen(channel: _to, sender: _username);
                    },
                  ));
                },
                icon: const Icon(Icons.call)),
          ],
        ),
        bottomSheet: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white),
          // color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Form(
                    child: TextFormField(
                  // initialValue: imageFireResult.toString(),
                  focusNode: _focusNode,
                  controller: txtMessage,
                  decoration: InputDecoration(
                      prefixIcon: IconButton(
                          onPressed: () {
                            var pvdImage = Provider.of<ChooseImageProvider>(
                                context,
                                listen: false);
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("ກະລຸນາເລືອກ"),
                                  content: Container(
                                    height: 150,
                                    child: Column(
                                      children: [
                                        Card(
                                          child: ListTile(
                                            onTap: () {
                                              pvdImage.chooseImage(
                                                  context, 'gallery');
                                            },
                                            title: const Text("ຮູບພາບ"),
                                            leading: Icon(Icons.image),
                                          ),
                                        ),
                                        Card(
                                          child: ListTile(
                                            onTap: () {
                                              pvdImage.chooseImage(
                                                  context, 'camera');
                                            },
                                            title: Text("ກ້ອງ"),
                                            leading: Icon(Icons.camera),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            // pvdImage.chooseImage(context);
                          },
                          icon: const Icon(Icons.camera_alt_sharp)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _attackfile();
                        },
                        icon: const Icon(Icons.attach_file),
                      ),
                      hintText: "Message"),
                )),
              ),
              //  const SizedBox(
              //     width: 5,
              //   ),
              sendImage == true && txtMessage.text.length <= 0
                  ? Consumer(
                      builder: (context,
                          ChooseImageProvider chooseImageProvider, child) {
                        var checkImage = chooseImageProvider.allImageToSendKey;
                        return IconButton(
                            onPressed: () {
                              if (checkImage.length <= 0) {
                                ShowAlert.showAlert(
                                    context, 'ກະລຸນາເລືອກຮູບພາບ');
                              }
                              var pvdConnect =
                                  Provider.of<ConnectSocketUDPProvider>(context,
                                      listen: false);
                              SendImageModel sendImageModel = SendImageModel(
                                  token: _username, channel: _to);
                              pvdConnect.sendImage(
                                  sendImageModel, context, 'IMAGE');
                            },
                            icon: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                const Icon(Icons.send_time_extension),
                                Text(
                                  "${checkImage.length}",
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ));
                      },
                    )
                  : IconButton(
                      onPressed: () {
                        sendtxtMessage();
                        setState(() {
                          sendImage;
                        });
                      },
                      icon: const Icon(Icons.send))
            ],
          ),
        ),
        body: Consumer(
          builder: (context, TextMessageProvider textMessagePro, child) {
            return Padding(
              padding: EdgeInsets.only(bottom: 55),
              child: ListView.builder(
                itemCount: textMessagePro.getMessage(
                            _to.toString(), _username.toString()) ==
                        null
                    ? 0
                    : textMessagePro
                        .getMessage(_to.toString(), _username.toString())
                        .length,
                reverse: true,
                itemBuilder: (context, index) {
                  TextMessageModel dataMessage = textMessagePro.getMessage(
                      _to.toString(), _username.toString())[index];
                  String uri = dataMessage.message.toString();
                  late Uint8List _bytes = base64.decode(uri.split(',').last);
                  // late VideoPlayerController _controller;

                  File file = File(uri);
                  late Future<void> _initializeVideoPlayerFuture;
                  late VideoPlayerController _controller =
                      VideoPlayerController.file(file);

                  _initializeVideoPlayerFuture = _controller.initialize();
                  _controller.setLooping(false);
                  _controller.pause();
                  if (dataMessage.sender.toString() == _username.toString()) {
                    switch (dataMessage.type) {
                      case "TEXT":
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RoundedChatMessage(
                                  message: dataMessage.message,
                                  hour: dataMessage.hour,
                                  minute: dataMessage.minute)
                            ],
                          ),
                        );
                      case "IMAGE":
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RoundedChatImage(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return ShowFullImageScreen(
                                          imageAddress: uri,
                                          sender: "ເຈົ້າ",
                                          hour: dataMessage.hour,
                                          minute: dataMessage.minute,
                                        );
                                      },
                                    ));
                                  },
                                  bytes: _bytes,
                                  hour: dataMessage.hour,
                                  minute: dataMessage.minute)
                            ],
                          ),
                        );
                      case "VIDEO":
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RoundedChatVideo(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return PlayVideoScreen(
                                          videoAddress: uri,
                                          sender: 'ເຈົ້າ',
                                          hour: dataMessage.hour,
                                          minute: dataMessage.minute);
                                    }));
                                  },
                                  hour: dataMessage.hour,
                                  minute: dataMessage.minute,
                                  controller: _controller)
                            ],
                          ),
                        );
                      case "AUDIO":
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 204, 240, 205),
                                    borderRadius: BorderRadius.circular(5)),
                                padding: EdgeInsets.all(3),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 230,
                                      child: Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                if (paths == null ||
                                                    paths.length < 0) {
                                                  setState(() {
                                                    paths = dataMessage.message;
                                                  });
                                                } else {
                                                  if (paths ==
                                                      dataMessage.message) {
                                                    if (assetsAudioPlayer
                                                            .currentPosition
                                                            .value
                                                            .inMilliseconds ==
                                                        0) {
                                                      assetsAudioPlayer.open(
                                                          Audio.file(dataMessage
                                                              .message));
                                                    } else {
                                                      if (assetsAudioPlayer
                                                          .isPlaying.value) {
                                                        assetsAudioPlayer
                                                            .pause();
                                                      } else {
                                                        assetsAudioPlayer
                                                            .play();
                                                      }
                                                    }
                                                  } else {
                                                    assetsAudioPlayer.open(
                                                        Audio.file(dataMessage
                                                            .message));

                                                    setState(() {
                                                      paths =
                                                          dataMessage.message;
                                                      playIndex =
                                                          dataMessage.message;
                                                    });
                                                  }
                                                }
                                              },
                                              icon: StreamBuilder(
                                                stream:
                                                    assetsAudioPlayer.isPlaying,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    final bool isPlaying =
                                                        snapshot.data!;
                                                    return playIndex !=
                                                            dataMessage.message
                                                        ? const Icon(
                                                            Icons.play_arrow)
                                                        : Icon(isPlaying
                                                            ? Icons.pause
                                                            : Icons.play_arrow);
                                                  } else {
                                                    return Icon(Icons.pause);
                                                  }
                                                },
                                              )),
                                          StreamBuilder(
                                            stream: assetsAudioPlayer
                                                .currentPosition,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                int position1 =
                                                    snapshot.data!.inSeconds;
                                                return playIndex !=
                                                        dataMessage.message
                                                    ? Text("0:0")
                                                    : Text(
                                                        '${position1.toInt() ~/ 60}:${position1.toInt() % 60}',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      );
                                              } else {
                                                return Text('0:0');
                                              }
                                            },
                                          ),
                                          PlayerBuilder.currentPosition(
                                            player: assetsAudioPlayer,
                                            builder: (context, position) {
                                              return Expanded(
                                                child: Slider(
                                                  activeColor: Colors.blue,
                                                  inactiveColor: Colors.grey,
                                                  min: 0.0,
                                                  max: dataMessage.long
                                                      .toDouble(),
                                                  value: playIndex !=
                                                          dataMessage.message
                                                      ? 0.0
                                                      : position.inSeconds
                                                          .toDouble(),
                                                  onChanged: (value) {
                                                    assetsAudioPlayer.seekBy(
                                                        const Duration(
                                                            seconds: 10));
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          playIndex == dataMessage.message
                                              ? GestureDetector(
                                                  onTap: () {
                                                    assetsAudioPlayer
                                                        .setPlaySpeed(1);
                                                    if (assetsAudioPlayer
                                                            .playSpeed.value >=
                                                        2.0) {
                                                      assetsAudioPlayer
                                                          .setPlaySpeed(0.5);
                                                    } else {
                                                      double playSpeed =
                                                          assetsAudioPlayer
                                                              .playSpeed.value;
                                                      assetsAudioPlayer
                                                          .setPlaySpeed(
                                                              playSpeed + 0.5);
                                                    }
                                                  },
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        width: 30,
                                                        height: 20,
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.blueGrey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                      ),
                                                      StreamBuilder(
                                                        stream:
                                                            assetsAudioPlayer
                                                                .playSpeed,
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                              .hasData) {
                                                            return Text(
                                                              '${snapshot.data}x',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            );
                                                          } else {
                                                            return const Text(
                                                                '1x');
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  ))
                                              : Text(
                                                  '${dataMessage.long ~/ 60}:${dataMessage.long % 60}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${dataMessage.hour}:${dataMessage.minute} ນ',
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      default:
                        return Text('data');
                    }
                  } else {
                    switch (dataMessage.type) {
                      case "TEXT":
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RoundedChatMessage(
                                  message: dataMessage.message,
                                  hour: dataMessage.hour,
                                  minute: dataMessage.minute)
                            ],
                          ),
                        );
                      case "IMAGE":
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RoundedChatImage(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return ShowFullImageScreen(
                                          imageAddress: uri,
                                          sender: "ເຈົ້າ",
                                          hour: dataMessage.hour,
                                          minute: dataMessage.minute,
                                        );
                                      },
                                    ));
                                  },
                                  bytes: _bytes,
                                  hour: dataMessage.hour,
                                  minute: dataMessage.minute)
                            ],
                          ),
                        );
                      case "VIDEO":
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RoundedChatVideo(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return PlayVideoScreen(
                                          videoAddress: uri,
                                          sender: 'ເຈົ້າ',
                                          hour: dataMessage.hour,
                                          minute: dataMessage.minute);
                                    }));
                                  },
                                  hour: dataMessage.hour,
                                  minute: dataMessage.minute,
                                  controller: _controller)
                            ],
                          ),
                        );
                      case "AUDIO":
                        //  int durationData = assetsAudioPlayer.current.
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 204, 240, 205),
                                    borderRadius: BorderRadius.circular(5)),
                                padding: EdgeInsets.all(3),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 230,
                                      child: Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                if (paths == null ||
                                                    paths.length < 0) {
                                                  setState(() {
                                                    paths = dataMessage.message;
                                                  });
                                                } else {
                                                  if (paths ==
                                                      dataMessage.message) {
                                                    if (assetsAudioPlayer
                                                            .currentPosition
                                                            .value
                                                            .inMilliseconds ==
                                                        0) {
                                                      assetsAudioPlayer.open(
                                                          Audio.file(dataMessage
                                                              .message));
                                                    } else {
                                                      if (assetsAudioPlayer
                                                          .isPlaying.value) {
                                                        assetsAudioPlayer
                                                            .pause();
                                                      } else {
                                                        assetsAudioPlayer
                                                            .play();
                                                      }
                                                    }
                                                  } else {
                                                    assetsAudioPlayer.open(
                                                        Audio.file(dataMessage
                                                            .message));

                                                    setState(() {
                                                      paths =
                                                          dataMessage.message;
                                                      playIndex =
                                                          dataMessage.message;
                                                    });
                                                  }
                                                }
                                              },
                                              icon: StreamBuilder(
                                                stream:
                                                    assetsAudioPlayer.isPlaying,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    final bool isPlaying =
                                                        snapshot.data!;
                                                    return playIndex !=
                                                            dataMessage.message
                                                        ? const Icon(
                                                            Icons.play_arrow)
                                                        : Icon(isPlaying
                                                            ? Icons.pause
                                                            : Icons.play_arrow);
                                                  } else {
                                                    return Icon(Icons.pause);
                                                  }
                                                },
                                              )),
                                          StreamBuilder(
                                            stream: assetsAudioPlayer
                                                .currentPosition,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                int position1 =
                                                    snapshot.data!.inSeconds;
                                                return playIndex !=
                                                        dataMessage.message
                                                    ? Text("0:0")
                                                    : Text(
                                                        '${position1.toInt() ~/ 60}:${position1.toInt() % 60}',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      );
                                              } else {
                                                return Text('0:0');
                                              }
                                            },
                                          ),
                                          PlayerBuilder.currentPosition(
                                            player: assetsAudioPlayer,
                                            builder: (context, position) {
                                              return Expanded(
                                                child: Slider(
                                                  activeColor: Colors.blue,
                                                  inactiveColor: Colors.grey,
                                                  min: 0.0,
                                                  max: dataMessage.long
                                                      .toDouble(),
                                                  value: playIndex !=
                                                          dataMessage.message
                                                      ? 0.0
                                                      : position.inSeconds
                                                          .toDouble(),
                                                  onChanged: (value) {
                                                    assetsAudioPlayer.seekBy(
                                                        const Duration(
                                                            seconds: 10));
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          playIndex == dataMessage.message
                                              ? GestureDetector(
                                                  onTap: () {
                                                    assetsAudioPlayer
                                                        .setPlaySpeed(1);
                                                    if (assetsAudioPlayer
                                                            .playSpeed.value >=
                                                        2.0) {
                                                      assetsAudioPlayer
                                                          .setPlaySpeed(0.5);
                                                    } else {
                                                      double playSpeed =
                                                          assetsAudioPlayer
                                                              .playSpeed.value;
                                                      assetsAudioPlayer
                                                          .setPlaySpeed(
                                                              playSpeed + 0.5);
                                                    }
                                                  },
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        width: 30,
                                                        height: 20,
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.blueGrey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                      ),
                                                      StreamBuilder(
                                                        stream:
                                                            assetsAudioPlayer
                                                                .playSpeed,
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                              .hasData) {
                                                            return Text(
                                                              '${snapshot.data}x',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            );
                                                          } else {
                                                            return const Text(
                                                                '1x');
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  ))
                                              : Text(
                                                  '${dataMessage.long ~/ 60}:${dataMessage.long % 60}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${dataMessage.hour}:${dataMessage.minute} ນ',
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      default:
                        return Text('data');
                    }
                  }
                },
              ),
            );
          },
        ));
  }

  checkVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    if (result!.files.single.path != null ||
        result.files.single.path!.length > 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CheckVideoScreen(
          videoAddress: result.files.single.path,
          sender: _username,
          channel: _to,
        );
      }));
    }
  }

  checkAudio() async {
    Navigator.pop(context);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result!.files.single.path != null ||
        result.files.single.path!.length > 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CheckAudioScreen(
          audioAddress: result.files.single.path,
          sender: _username,
          channel: _to,
        );
      }));
    }
  }

  _attackfile() {
    var pvdImage = Provider.of<ChooseImageProvider>(context, listen: false);
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            height: 250,
            width: double.infinity,
            child: Card(
              margin: EdgeInsets.only(
                bottom: 50,
                left: 10,
                right: 10,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomAttackFile(
                          image: 'assets/image/document.png',
                          name: 'ເອກະສານ',
                          onTap: () {},
                        ),
                        CustomAttackFile(
                            image: 'assets/image/camera.jpg',
                            name: 'ກ້ອງ',
                            onTap: () {
                              pvdImage.chooseImage(context, 'camera');
                            }),
                        CustomAttackFile(
                            image: 'assets/image/gallery.png',
                            name: 'ຮູບພາບ',
                            onTap: () {
                              pvdImage.chooseImage(context, 'gallery');
                            })
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomAttackFile(
                            image: 'assets/image/audio.jpeg',
                            name: 'ສຽງ',
                            onTap: () {
                              checkAudio();
                            }),
                        CustomAttackFile(
                            image: 'assets/image/video.jpeg',
                            name: 'ວິດີໂອ',
                            onTap: () {
                              checkVideo();
                            }),
                        CustomAttackFile(
                            image: 'assets/image/recodevideo.png',
                            name: 'ບັນທຶກວິດີໂອ',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return CameraScreen(
                                    sender: _username,
                                    channel: _to,
                                  );
                                },
                              ));
                            })
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
