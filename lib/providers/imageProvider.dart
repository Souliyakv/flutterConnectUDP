import 'dart:io';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../model/getImageModel.dart';

class ChooseImageProvider with ChangeNotifier {
  File? file;
  late Uint8List imagebytes = new Uint8List(0);
  var allImageToSend = {};
  List<int> allImageToSendKey = [];
  var sendIndex = {};
  var resendIndex = {};
  var dataListRefund = {};
  void chooseImage(BuildContext context) async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    file = File(image!.path);
    imagebytes = await file!.readAsBytes();
    var keyIndex;

    keyIndex = DateTime.now().millisecondsSinceEpoch;

    allImageToSendKey.add(keyIndex);
    int chunkSize = 1800;

    List<Uint8List> sperate = [];
    for (int i = 0; i < imagebytes.length; i += chunkSize) {
      int end =
          i + chunkSize < imagebytes.length ? i + chunkSize : imagebytes.length;
      sperate.add(imagebytes.sublist(i, end));
    }
    allImageToSend.addAll({keyIndex: sperate});
    notifyListeners();
  }

  void clearImage() {
    allImageToSendKey.clear();
  }

  void addsendIndex(var trans) {
    sendIndex.addAll({trans: 0});
  }

  sendMessage(ConfirmToSendModel dataToSend) {
    // var pvdConnect = Provider.of<ConnectSocketUDPProvider>(context,listen: false);
    var sendIndexData = dataToSend.start + sendIndex[dataToSend.trans];
    int total = dataToSend.end - dataToSend.start;
    // print(sendIndexData < dataToSend.end);
    if (sendIndexData < dataToSend.end) {
      print("send");

      SendMessageIMGModel sendMessageIMGModel = SendMessageIMGModel(
          message: allImageToSend[dataToSend.trans][sendIndexData],
          index: int.parse(sendIndexData.toString()),
          total: total,
          round: sendIndex[dataToSend.trans] + 1,
          address: dataToSend.address,
          end: dataToSend.end,
          port: dataToSend.port,
          start: dataToSend.start,
          sumData: allImageToSend[dataToSend.trans][sendIndexData].length,
          trans: dataToSend.trans);

      sendIndex.update(dataToSend.trans,
          (value) => int.parse(sendIndex[dataToSend.trans].toString()) + 1);
      return sendMessageIMGModel;
    } else {
      SendMessageIMGModel sendMessageIMGModel = SendMessageIMGModel(
          message: '0',
          index: 0,
          total: 0,
          round: 0,
          address: '0',
          end: 0,
          port: 0,
          start: 0,
          sumData: 0,
          trans: 0);
      return sendMessageIMGModel;
    }
  }

  success(var trans) {
    allImageToSend.remove(trans);
    allImageToSendKey.remove(trans);
  }

  sendRefunData(RefunDataModel refunDataModel, BuildContext context) {
    resendIndex.addAll({refunDataModel.trans: 0});
    dataListRefund.addAll({refunDataModel.trans: refunDataModel.message});
    resend(refunDataModel, context);
  }

  resend(RefunDataModel refunDataModel, BuildContext context) {
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    if (resendIndex[refunDataModel.trans] !=
        dataListRefund[refunDataModel.trans].length) {
      int dataIndex = dataListRefund[refunDataModel.trans]
          [resendIndex[refunDataModel.trans]];
      ResendDataModel resendDataModel = ResendDataModel(
          message: allImageToSend[refunDataModel.trans][dataIndex],
          total: dataListRefund[refunDataModel.trans].length,
          round: resendIndex[refunDataModel.trans] + 1,
          sumData: allImageToSend[refunDataModel.trans][dataIndex].length,
          address: refunDataModel.address,
          port: refunDataModel.port,
          trans: refunDataModel.trans,
          type: refunDataModel.type,
          index: dataListRefund[refunDataModel.trans]
              [resendIndex[refunDataModel.trans]]);
      // resend
      pvdConnect.resend(resendDataModel);
      resendIndex.update(
          refunDataModel.trans,
          (value) =>
              int.parse(resendIndex[refunDataModel.trans].toString()) + 1);
    }
  }
}
