import 'dart:io';

import 'package:flutter/services.dart';

Future<void> main() async {
  final ip = InternetAddress.anyIPv4;
  final server = await ServerSocket.bind(ip, 8080);
  print('server ${ip.address}:8080');
  server.listen((Socket event) {
    handleConnection(event);
  });
  final socket = await Socket.connect('192.168.0.131', 8080);
}

List<Socket> clients = [];

void handleConnection(Socket client) {
  print(
      'server: connect from ${client.remoteAddress.address}:${client.remotePort}');
  client.listen((Uint8List data) {
    final message = String.fromCharCodes(data);
    for (final c in clients) {
      c.write('server $message');
    }
    clients.add(client);
    client.write("Server you are logged in as $message");
  }, onError: (error) {
    print(error);
    client.close();
  }, onDone: () {
    print('server Client left');
    client.cast();
  });
}
