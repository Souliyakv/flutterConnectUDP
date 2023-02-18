import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  const RoundedButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(text.toString()));
  }
}
