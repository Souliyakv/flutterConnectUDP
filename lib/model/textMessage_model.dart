class TextMessageModel {
  // {"message": msg, "sender": sender, "hour": hour, "minute": minute}
  late String message;
  late String sender;
  late String hour;
  late String minute;
  late String channel;
  late String type;

  TextMessageModel(
      {required this.message,
      required this.sender,
      required this.hour,
      required this.minute,
      required this.channel,
      required this.type});
}

class SendTextMessageModel {
  late String message;
  late String channel;
  late String sender;
  late String hour;
  late String minute;
  late String token;
  SendTextMessageModel(
      {required this.message,
      required this.channel,
      required this.sender,
      required this.hour,
      required this.minute,
      required this.token});
}
