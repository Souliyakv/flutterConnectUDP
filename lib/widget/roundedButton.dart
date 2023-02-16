import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  const MyWidget({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(text.toString()));
  }
}
