class RequestCallModel {
  late String channel;
  late String sender;
  RequestCallModel({required this.channel, required this.sender});
}

class AcceptCallModel {
  late String channel;
  late String sender;
  late String address;
  late int port;
  AcceptCallModel(
      {required this.address,
      required this.port,
      required this.channel,
      required this.sender});
}

class AppCallingModel {
  late String address;
  late int port;
  var message;
  AppCallingModel(
      {required this.address, required this.message, required this.port});
}

class HangUpCallModel {
  late String address;
  late int port;
  HangUpCallModel({required this.address, required this.port});
}
