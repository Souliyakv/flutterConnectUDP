import 'package:flutter/material.dart';

class RoundedInPutField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? labelText;
  final TextInputType? keyboardType;
  const RoundedInPutField(
      {super.key, this.controller, required this.validator, this.labelText,this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(keyboardType: keyboardType,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}
