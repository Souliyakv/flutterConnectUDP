import 'dart:convert';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:demoudp/model/imageModel.dart';
import 'package:demoudp/model/textMessage_model.dart';
import 'package:demoudp/model/typingStatusModel.dart';
import 'package:demoudp/page/cameraPage.dart';
import 'package:demoudp/page/checkAudio.dart';
import 'package:demoudp/page/checkVideo.dart';
import 'package:demoudp/page/playVideo.dart';
import 'package:demoudp/page/recodeAudio.dart';
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
  final assetsAudioPlayer = AssetsAudioPlayer();
  String paths = '';
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
  double durationData = 1.0;

  void sendtxtMessage() {
    TextMessageModel textMessageModel = TextMessageModel(
        message: txtMessage.text,
        sender: _username,
        hour: DateTime.now().hour.toString(),
        minute: DateTime.now().minute.toString(),
        channel: _to,
        type: "TEXT");
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
                            "https://upload.wikimedia.org/wikipedia/commons/7/7a/Siri_Logo_in_2022.png"),
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
                  checkVideo();
                },
                icon: const Icon(Icons.video_camera_back)),
            IconButton(
                onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (context){
            return RecodeAudioScreen(sender: _username,channel: _to,);
          }));
                },
                icon: const Icon(Icons.record_voice_over_sharp))
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
                itemCount: textMessagePro.getMessage(_to.toString()) == null
                    ? 0
                    : textMessagePro.getMessage(_to.toString()).length,
                reverse: true,
                itemBuilder: (context, index) {
                  TextMessageModel dataMessage =
                      textMessagePro.getMessage(_to.toString())[index];
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
                    if (dataMessage.type == 'TEXT') {
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
                                  GestureDetector(
                                      onLongPress: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: dataMessage.message));
                                      },
                                      child:
                                          Text(dataMessage.message.toString())),
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
                    } else if (dataMessage.type == "IMAGE") {
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
                                  GestureDetector(
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
                                    child: Container(
                                      height: 200,
                                      width: 200,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: MemoryImage(_bytes),
                                              fit: BoxFit.cover)),
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
                    } else if (dataMessage.type == 'VIDEO') {
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
                                  GestureDetector(
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
                                    child: Container(
                                      height: 180,
                                      width: 180,
                                      child: AspectRatio(
                                        aspectRatio:
                                            _controller.value.aspectRatio,
                                        child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              VideoPlayer(_controller),
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
                                    '${dataMessage.hour}:${dataMessage.minute} ນ',
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (dataMessage.type == 'AUDIO') {
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
                                    width: 180,
                                    child: Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              playAudio(dataMessage.message);
                                            },
                                            icon: Icon(assetsAudioPlayer
                                                    .isPlaying.value
                                                ? Icons.pause
                                                : Icons.play_arrow)),
                                        Text(
                                          '${position.toInt() ~/ 60}:${position.toInt() % 60}',
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        Expanded(
                                          child: Slider(
                                            min: 0.0,
                                            max: durationData,
                                            value: position,
                                            onChanged: (value) {
                                              setState(() {
                                                position = value;
                                              });
                                            },
                                          ),
                                        ),
                                        Text(
                                          '${durationData.toInt() ~/ 60}:${durationData.toInt() % 60}',
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
                    } else {
                      return Text('data');
                    }
                  } else {
                    if (dataMessage.type == 'TEXT') {
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
                                  GestureDetector(
                                      onLongPress: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: dataMessage.message));
                                      },
                                      child:
                                          Text(dataMessage.message.toString())),
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
                    } else if (dataMessage.type == "IMAGE") {
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
                                  GestureDetector(
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
                                    child: Container(
                                      height: 200,
                                      width: 200,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: MemoryImage(_bytes),
                                              fit: BoxFit.cover)),
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
                    } else if (dataMessage.type == 'VIDEO') {
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
                                  GestureDetector(
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
                                    child: Container(
                                      height: 180,
                                      width: 180,
                                      child: AspectRatio(
                                        aspectRatio:
                                            _controller.value.aspectRatio,
                                        child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              VideoPlayer(_controller),
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
                                    '${dataMessage.hour}:${dataMessage.minute} ນ',
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (dataMessage.type == 'AUDIO') {
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
                                    width: 180,
                                    child: Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                                 playAudio(dataMessage.message);
                                            },
                                            icon: Icon(assetsAudioPlayer
                                                    .isPlaying.value
                                                ? Icons.pause
                                                : Icons.play_arrow)),
                                        Text(
                                          '${position.toInt() ~/ 60}:${position.toInt() % 60}',
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        Expanded(
                                          child: Slider(
                                            min: 0.0,
                                            max: durationData,
                                            value: position,
                                            onChanged: (value) {
                                              setState(() {
                                                position = value;
                                              });
                                            },
                                          ),
                                        ),
                                        Text(
                                          '${durationData.toInt() ~/ 60}:${durationData.toInt() % 60}',
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
                    } else {
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

  void playAudio(String path) {
    if (paths == null || paths.length < 0) {
      setState(() {
        paths = path;
      });
    } else {
      if (paths == path) {
        if (assetsAudioPlayer.currentPosition.value.inMilliseconds == 0) {
          assetsAudioPlayer.open(Audio.file(path));
        } else {
          if (assetsAudioPlayer.isPlaying.value) {
            assetsAudioPlayer.pause();
          } else {
            assetsAudioPlayer.play();
          }
        }
      } else {
        assetsAudioPlayer.open(Audio.file(path));
        setState(() {
          paths = path;
        });
      }
    }
  }
}
