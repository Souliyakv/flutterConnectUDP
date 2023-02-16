import 'package:flutter/material.dart';

class ShowAlert {
  static void showAlert(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(msg.toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("ຕົກລົງ"))
          ],
        );
      },
    );
  }
}
