class GetTotalModel {
  late int trans;
  late int total;
  late String address;
  var port;
  GetTotalModel(
      {required this.trans,
      required this.total,
      required this.address,
      required this.port});
}

class DetailImageModel {
  late String trans;
  late String sender;
  late String channel;
  late String type;
  DetailImageModel({
    required this.trans,
    required this.sender,
    required this.channel,
    required this.type
  });
}

class ConfirmToSendModel {
  late int start;
  late int end;
  late String address;
  late int port;
  late int trans;
  ConfirmToSendModel(
      {required this.start,
      required this.end,
      required this.address,
      required this.port,
      required this.trans});
}

class SendMessageIMGModel {
  var message;
  late int index;
  late int total;
  late int round;
  late int start;
  late int end;
  late int sumData;
  late String address;
  late int port;
  late int trans;
  SendMessageIMGModel(
      {required this.message,
      required this.index,
      required this.total,
      required this.round,
      required this.address,
      required this.end,
      required this.port,
      required this.start,
      required this.sumData,
      required this.trans});
}

class PushBufferToImageModel {
  var message;
  late int index;
  late int total;
  late int round;
  late int sumData;
  late int start;
  late int end;
  late String address;
  late int port;
  late int trans;

  PushBufferToImageModel(
      {required this.message,
      required this.index,
      required this.total,
      required this.round,
      required this.sumData,
      required this.address,
      required this.end,
      required this.port,
      required this.start,
      required this.trans});
}

class RefunDataModel {
  var message;
  late int total;
  late int round;
  late int sumData;
  late String address;
  late int port;
  late int trans;
  late String type;
  RefunDataModel(
      {required this.message,
      required this.total,
      required this.round,
      required this.sumData,
      required this.address,
      required this.port,
      required this.trans,
      required this.type});
}

class SendSuccessModel {
  late int trans;
  late String address;
  late int port;
  SendSuccessModel(
      {required this.address, required this.port, required this.trans});
}

class ResendDataModel {
  var message;
  late int total;
  late int round;
  late int sumData;
  late String address;
  late int port;
  late int trans;
  late String type;
  late int index;
  ResendDataModel(
      {required this.message,
      required this.total,
      required this.round,
      required this.sumData,
      required this.address,
      required this.port,
      required this.trans,
      required this.type,
      required this.index});
}

class GetResendDataModel {
  var message;
  late String type;
  late int total;
  late int round;
  late int index;
  late int sumData;
  late String address;
  late int port;
  late int trans;
  GetResendDataModel(
      {required this.address,
      required this.index,
      required this.message,
      required this.port,
      required this.round,
      required this.sumData,
      required this.total,
      required this.trans,
      required this.type});
}
