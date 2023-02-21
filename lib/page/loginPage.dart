import 'package:demoudp/model/connectSocketUDP_model.dart';
import 'package:demoudp/page/chatPage.dart';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:demoudp/widget/roundedButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/roundedInputField.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  final channel = TextEditingController();
  final formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  RoundedInPutField(
                    keyboardType: TextInputType.text,
                    controller: username,
                    labelText: "Username",
                    validator: (value) {
                      if (value!.isEmpty || value.length <= 0) {
                        return "Please Enter Username";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  RoundedInPutField(
                    keyboardType: TextInputType.text,
                    controller: password,
                    labelText: "Password",
                    validator: (value) {
                      if (value!.isEmpty || value.length <= 0) {
                        return "Please Enter Password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  RoundedInPutField(
                    keyboardType: TextInputType.number,
                    controller: channel,
                    labelText: "Channel",
                    validator: (value) {
                      if (value!.isEmpty || value.length <= 0) {
                        return "Please Enter Channel";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  RoundedButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          LoginModel loginMD = LoginModel(
                              username: username.text, password: password.text);
                          var provider = Provider.of<ConnectSocketUDPProvider>(
                              context,
                              listen: false);
                          provider.login(loginMD, context);
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ChatPage(
                                  username: username.text,
                                  password: password.text,
                                  channel: channel.text);
                            },
                          ));
                        }
                      },
                      text: "ເຂົ້າສູ່ລະບົບ")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
