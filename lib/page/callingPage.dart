import 'package:demoudp/model/callingModel.dart';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallingScreen extends StatefulWidget {
  final String sender;
  final String channel;
  const CallingScreen({super.key, required this.channel, required this.sender});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {

  @override
  void initState() {
    super.initState();
    // _startCapture();
    startRequest(context);
  }

  void startRequest(BuildContext context) {
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    RequestCallModel requestCallModel =
        RequestCallModel(channel: widget.channel, sender: widget.sender);
    pvdConnect.requestCall(requestCallModel);
  }

  // Future<void> _startCapture() async {
  //   print('start');
  //   await _plugin.start(listener, onError, sampleRate: 16000, bufferSize: 3000);
  // }

  // Future<void> _stopCapture() async {
  //   await _plugin.stop();
  // }

  // void listener(dynamic obj) {
  //   var buffer = Float64List.fromList(obj.cast<double>());
  //   print(buffer);
  //   print('object');
  // }

  // void onError(Object e) {
  //   print(e);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 4, 59, 33),
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 4, 59, 33),
          title: const Text("Ent to end encrypted")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 80,
            child: Column(
              children: [
                Text(
                  '${widget.channel}',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                const Text(
                  'ກຳລັງໂທ...',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              ],
            ),
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 420,
                width: double.infinity,
                color: Colors.blueGrey,
                child: const Icon(
                  Icons.person,
                  size: 300,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    // _stopCapture();
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.call_end),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.video_call,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.mic_external_off,
                      color: Colors.white,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
