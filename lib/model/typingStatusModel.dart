class SendTypingStatusModel {
  late bool status;
  late String channel;
  late String token;
  SendTypingStatusModel(
      {required this.status, required this.channel, required this.token});
}

class GetTypingStatusModel {
  late bool status;
  late String channel;
  GetTypingStatusModel({required this.status, required this.channel});
}
