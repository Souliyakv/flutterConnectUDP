import 'dart:convert';

import 'package:demoudp/model/imageModel.dart';
import 'package:demoudp/model/textMessage_model.dart';
import 'package:demoudp/model/typingStatusModel.dart';
import 'package:demoudp/page/playVideo.dart';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:demoudp/providers/imageProvider.dart';
import 'package:demoudp/providers/statusTypingProvider.dart';
import 'package:demoudp/providers/textMessage_provider.dart';
import 'package:demoudp/widget/showAlert.dart';
import 'package:demoudp/widget/showFullImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
                      pvdConnect.sendImage(sendImageModel, context);
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
            IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
            IconButton(
                onPressed: () {
                  var result = {};

                  result.addAll({
                    '2': ['a', 2]
                  });
                  print(result['2'][1]);
                },
                icon: const Icon(Icons.more_vert))
          ],
        ),
        bottomSheet: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white),
          // color: Colors.white,
          child: Form(
              child: TextFormField(
            focusNode: _focusNode,
            controller: txtMessage,
            decoration: InputDecoration(
                prefixIcon: IconButton(
                    onPressed: () {
                      var pvdImage = Provider.of<ChooseImageProvider>(context,
                          listen: false);
                      pvdImage.chooseImage(context);
                    },
                    icon: const Icon(Icons.camera_alt_sharp)),
                suffixIcon: sendImage == true && txtMessage.text.length <= 0
                    ? Consumer(
                        builder: (context,
                            ChooseImageProvider chooseImageProvider, child) {
                          var checkImage =
                              chooseImageProvider.allImageToSendKey;
                          return IconButton(
                              onPressed: () {
                                if (checkImage.length <= 0) {
                                  ShowAlert.showAlert(
                                      context, 'ກະລຸນາເລືອກຮູບພາບ');
                                }
                                var pvdConnect =
                                    Provider.of<ConnectSocketUDPProvider>(
                                        context,
                                        listen: false);
                                SendImageModel sendImageModel = SendImageModel(
                                    token: _username, channel: _to);
                                pvdConnect.sendImage(sendImageModel, context);
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
                        icon: const Icon(Icons.send)),
                hintText: "Message"),
          )),
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
                  if (dataMessage.sender.toString() == _username.toString()) {
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
                                dataMessage.type == "TEXT"
                                    ? GestureDetector(
                                        onLongPress: () {
                                          Clipboard.setData(new ClipboardData(
                                              text: dataMessage.message));
                                        },
                                        child: Text(
                                            dataMessage.message.toString()))
                                    : dataMessage.type == "IMAGE"
                                        ? GestureDetector(
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
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
                                                      image:
                                                          MemoryImage(_bytes),
                                                      fit: BoxFit.cover)),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return PlayVideoScreen(
                                                    videoAddress: uri,
                                                    sender: dataMessage.sender,
                                                    hour: dataMessage.hour,
                                                    minute: dataMessage.minute);
                                              }));
                                            },
                                            child: Container(
                                                height: 100,
                                                width: 100,
                                                decoration: const BoxDecoration(
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            "https://static.thenounproject.com/png/375319-200.png"),
                                                        fit: BoxFit.cover))),
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
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.all(3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              dataMessage.type == "TEXT"
                                  ? GestureDetector(
                                      onLongPress: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: dataMessage.message));
                                      },
                                      child:
                                          Text(dataMessage.message.toString()))
                                  : dataMessage.type == "IMAGE"
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                              builder: (context) {
                                                return ShowFullImageScreen(
                                                  imageAddress: uri,
                                                  sender: dataMessage.sender,
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
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return PlayVideoScreen(
                                                  videoAddress: uri,
                                                  sender: dataMessage.sender,
                                                  hour: dataMessage.hour,
                                                  minute: dataMessage.minute);
                                            }));
                                          },
                                          child: Container(
                                              height: 100,
                                              width: 100,
                                              decoration: const BoxDecoration(
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          "https://static.thenounproject.com/png/375319-200.png"),
                                                      fit: BoxFit.cover))),
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
                },
              ),
            );
          },
        ));
  }
}
