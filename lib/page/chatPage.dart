import 'package:flutter/material.dart';


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
            title: Text("Luck"),
            subtitle: Row(
              children: const [
                Icon(
                  Icons.check,
                  size: 20,
                ),
                Text("ໂດຍຍ"),
              ],
            ),
            trailing: Text("14/2/23"),
            leading: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                      image: NetworkImage(
                          "https://img.freepik.com/premium-photo/portrait-adult-thai-student-university-student-uniform-asian-beautiful-young-girl-standing_477666-2194.jpg?w=2000"),
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
