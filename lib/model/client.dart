import 'dart:io';

import 'package:flutter/foundation.dart';

Future<void> main() async {
  final socket = await Socket.connect("192.168.0.131", 8080);
  print(
      "Client: Connected to ${socket.remoteAddress.address}: ${socket.remotePort}");

  socket.listen((Uint8List data) {
    final serverResponse = String.fromCharCodes(data);
    print("CLient $serverResponse");
  }, onError: (error) {
    print("colent:$error");
    socket.destroy();
  }, onDone: () {
    print('Client: server left');
    socket.destroy();
  });

  String? usernsme;
  do {
    print("client:please enter a useername");
    usernsme = stdin.readLineSync();
  } while (usernsme == null || usernsme.isEmpty);
  socket.write(usernsme);
}
