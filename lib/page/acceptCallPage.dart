import 'package:demoudp/model/callingModel.dart';
import 'package:demoudp/providers/call_provider.dart';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AcceptCallingScreen extends StatefulWidget {
  final String channel;
  final String sender;
  final String address;
  final port;
  const AcceptCallingScreen(
      {super.key,
      required this.address,
      required this.channel,
      required this.port,
      required this.sender});

  @override
  State<AcceptCallingScreen> createState() => _AcceptCallingScreenState();
}

class _AcceptCallingScreenState extends State<AcceptCallingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 4, 59, 33),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(75),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDqZLNNtpV-cNZfqbScWb3_Ny0C15rPO9mgg&usqp=CAU'),
                    fit: BoxFit.cover,
                  )),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              '${widget.sender}',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'ສາຍໂທເຂົ້າ...',
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () {},
                child: const Icon(
                  Icons.call_end,
                  color: Colors.red,
                )),
            TextButton(
                onPressed: () {
                  accept();
                },
                child: Icon(Icons.call)),
          ],
        ),
      ),
    );
  }

  void accept() {
    var pvdCallStream = Provider.of<CallProvider>(context, listen: false);
    pvdCallStream.record(context, widget.address, widget.port);
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    AcceptCallModel acceptCallModel = AcceptCallModel(
        address: widget.address,
        port: widget.port,
        sender: widget.sender,
        channel: widget.channel);
    pvdConnect.acceptCall(acceptCallModel, context);
  }
}
