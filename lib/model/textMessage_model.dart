class TextMessageModel {
  // {"message": msg, "sender": sender, "hour": hour, "minute": minute}
  var message;
  late String sender;
  late String hour;
  late String minute;
  late String channel;
  late String type;
  late int long;

  TextMessageModel(
      {required this.message,
      required this.sender,
      required this.hour,
      required this.minute,
      required this.channel,
      required this.type,
      required this.long});
}

class SendTextMessageModel {
  var message;
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
