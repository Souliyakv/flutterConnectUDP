import 'package:demoudp/page/loginPage.dart';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:demoudp/providers/getImageProvider.dart';
import 'package:demoudp/providers/imageProvider.dart';
import 'package:demoudp/providers/statusTypingProvider.dart';
import 'package:demoudp/providers/textMessage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          return TextMessageProvider();
        }),
        ChangeNotifierProvider(create: (context) {
          return ConnectSocketUDPProvider();
        }),
        ChangeNotifierProvider(create: (context){
          return StatusTypingProvider();
        }),
        ChangeNotifierProvider(create: (context){
          return ChooseImageProvider();
        }),
        ChangeNotifierProvider(create: (context){
          return GetImageProvider();
        })
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home:const LoginPage(),
      ),
    );
  }
}
