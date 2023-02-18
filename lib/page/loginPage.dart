import 'package:demoudp/page/chatPage.dart';
import 'package:demoudp/widget/roundedButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

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
                  SizedBox(
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
                  SizedBox(
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
                  SizedBox(
                    height: 25,
                  ),
                  RoundedButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
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
