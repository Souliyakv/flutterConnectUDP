import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatify"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Somchit"),
            subtitle: Text("ໂດຍຍ"),
            trailing: Text("14/2/23"),
            leading: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                      image: NetworkImage(
                          "https://parade.com/.image/t_share/MTkwNTgxMzY0NzA2ODQ1ODIx/whats-world-population-jpg.jpg"),
                      fit: BoxFit.cover)),
              height: 40,
              width: 40,
            ),
          );
        },
      ),
    );
  }
}
