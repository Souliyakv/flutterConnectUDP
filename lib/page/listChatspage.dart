import 'package:demoudp/page/chatPage.dart';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:demoudp/providers/getImageProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListOfChatPageScreen extends StatefulWidget {
  final String username;
  final String password;
  const ListOfChatPageScreen(
      {super.key, required this.password, required this.username});

  @override
  State<ListOfChatPageScreen> createState() => _ListOfChatPageScreenState();
}

class _ListOfChatPageScreenState extends State<ListOfChatPageScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var provider =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    provider.findUserslist(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ສົນທະນາ")),
      body: Consumer(
        builder: (context, GetImageProvider getImageProvider, child) {
          return ListView.builder(
            itemCount: getImageProvider.userList.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return ChatPage(
                            username: widget.username,
                            password: widget.password,
                            channel:
                                getImageProvider.userList[index].toString());
                      },
                    ));
                  },
                  title: Text(getImageProvider.userList[index].toString()),
                  leading: CircleAvatar(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: const DecorationImage(
                              image: NetworkImage(
                                  'https://images.pexels.com/photos/1391495/pexels-photo-1391495.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                              fit: BoxFit.cover)),
                    ),
                  ),
                  subtitle: const Text("ໂດຍຍ"),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.chat),
      ),
    );
  }
}
