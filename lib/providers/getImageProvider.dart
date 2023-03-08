import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:demoudp/model/getImageModel.dart';
import 'package:demoudp/providers/connectSocketUDP_provider.dart';
import 'package:demoudp/providers/textMessage_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../model/textMessage_model.dart';

class GetImageProvider with ChangeNotifier {
  var _start = {};
  var _end = {};
  var missingIndex = {};
  List<int> checkTimeoutIndex = [];
  var total = {};
  var totalToCheck = {};
  int roundTosend = 100;
  var dataArrCheck = {};
  var dataArr = {};
  var checkTimeout = {};
  late Timer timeOut;
  var detailDataImage = {};

  addDetailImage(DetailImageModel detailImageModel) {
    detailDataImage.addAll({
      detailImageModel.trans: [
        detailImageModel.sender.toString(),
        detailImageModel.channel.toString(),
        detailImageModel.type.toString(),
        detailImageModel.long
      ]
    });
    print(detailImageModel.type);
  }

  sendTotal(GetTotalModel sendTotalModel, BuildContext context) {
    _start.addAll({sendTotalModel.trans: 0});
    _end.addAll({sendTotalModel.trans: roundTosend});
    missingIndex.addAll({sendTotalModel.trans: []});
    checkTimeoutIndex.remove(sendTotalModel.trans);
    checkTimeoutIndex.add(sendTotalModel.trans);

    dataArrCheck.addAll({sendTotalModel.trans: []});
    total.addAll({sendTotalModel.trans: sendTotalModel.total});

    totalToCheck.addAll({sendTotalModel.trans: sendTotalModel.total});
    genData(sendTotalModel);

    if (total[sendTotalModel.trans] <= _end[sendTotalModel.trans]) {
      _end.update(sendTotalModel.trans, (value) => total[sendTotalModel.trans]);
    }
    confirmToSend(sendTotalModel, context);
  }

  confirmToSend(GetTotalModel getTotalModel, BuildContext context) {
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);

    if (_start[getTotalModel.trans] >= total[getTotalModel.trans]) {
      print('Success');
    } else {
      addDataToCheck(_start[getTotalModel.trans], _end[getTotalModel.trans],
          getTotalModel.trans);
      checkTimeout.addAll({getTotalModel.trans: getTotalModel});
      waitTimeOutToCheck(getTotalModel, context);

      ConfirmToSendModel dataConfirm = ConfirmToSendModel(
          start: _start[getTotalModel.trans],
          end: _end[getTotalModel.trans],
          address: getTotalModel.address,
          port: getTotalModel.port,
          trans: getTotalModel.trans);

      pvdConnect.confirmToSend(dataConfirm);

      int checkEnd = _end[getTotalModel.trans] + roundTosend;

      if (checkEnd >= total[getTotalModel.trans]) {
        _start.update(
            getTotalModel.trans,
            (value) =>
                int.parse(_start[getTotalModel.trans].toString()) +
                roundTosend);
        _end.update(getTotalModel.trans, (value) => total[getTotalModel.trans]);
      } else {
        _start.update(
            getTotalModel.trans,
            (value) =>
                int.parse(_start[getTotalModel.trans].toString()) +
                roundTosend);
        _end.update(
            getTotalModel.trans,
            (value) =>
                int.parse(_end[getTotalModel.trans].toString()) + roundTosend);
      }
    }
  }

  pushBufferToImage(
      PushBufferToImageModel pushBufferToImageModel, BuildContext context) {
    // print(pushBufferToImageModel.index);

    if (dataArr[pushBufferToImageModel.trans] != null) {
      if (pushBufferToImageModel.message.length ==
          pushBufferToImageModel.sumData) {
        print('remove');
        var result = removeDataToCheck(pushBufferToImageModel);
        if (result == true) {
          removeAndAdds(pushBufferToImageModel);
          dataArrCheck[pushBufferToImageModel.trans]
              .add(pushBufferToImageModel.index);
        }
        if (pushBufferToImageModel.trans == pushBufferToImageModel.round) {
          GetTotalModel getTotalModel = GetTotalModel(
              trans: pushBufferToImageModel.trans,
              total: pushBufferToImageModel.total,
              address: pushBufferToImageModel.address,
              port: pushBufferToImageModel.port);
          convertToImage(getTotalModel, context);
        }
      }
    }
  }

  convertToImage(
      GetTotalModel pushBufferToImageModel, BuildContext context) async {
    var provider = Provider.of<TextMessageProvider>(context, listen: false);
    timeOut.cancel();

    List<dynamic> newList = [];
    newList.clear();
    print("CV");
    if (missingIndex[pushBufferToImageModel.trans] == null ||
        missingIndex[pushBufferToImageModel.trans].length == 0) {
      if (dataArrCheck[pushBufferToImageModel.trans].length ==
          totalToCheck[pushBufferToImageModel.trans]) {
        for (int i = 0; i < dataArr[pushBufferToImageModel.trans].length; i++) {
          newList.addAll(
              jsonDecode(dataArr[pushBufferToImageModel.trans][i].toString()));
        }

        if (detailDataImage[pushBufferToImageModel.trans.toString()][2] ==
            'VIDEO') {
          Uint8List bytes = Uint8List.fromList(newList.cast<int>());
          final dir = await getApplicationDocumentsDirectory();
          File file = File("${dir.path}/" +
              DateTime.now().millisecondsSinceEpoch.toString() +
              ".mp4");
          await file.writeAsBytes(bytes);
          print("Save to :${file.path}");
          TextMessageModel textMessageModel = TextMessageModel(
              message: file.path,
              sender: detailDataImage[pushBufferToImageModel.trans.toString()]
                      [0]
                  .toString(),
              hour: DateTime.now().hour.toString(),
              minute: DateTime.now().minute.toString(),
              channel: detailDataImage[pushBufferToImageModel.trans.toString()]
                      [1]
                  .toString(),
              type: detailDataImage[pushBufferToImageModel.trans.toString()][2]
                  .toString(),long: 1);
          provider.addTextMessage(textMessageModel);
        } else if (detailDataImage[pushBufferToImageModel.trans.toString()]
                [2] ==
            'AUDIO') {
          Uint8List bytes = Uint8List.fromList(newList.cast<int>());
          final dir = await getApplicationDocumentsDirectory();
          File file = File("${dir.path}/" +
              DateTime.now().millisecondsSinceEpoch.toString() +
              ".mp3");
          await file.writeAsBytes(bytes);
          print("Save to :${file.path}");
          TextMessageModel textMessageModel = TextMessageModel(
              message: file.path,
              sender: detailDataImage[pushBufferToImageModel.trans.toString()]
                      [0]
                  .toString(),
              hour: DateTime.now().hour.toString(),
              minute: DateTime.now().minute.toString(),
              channel: detailDataImage[pushBufferToImageModel.trans.toString()]
                      [1]
                  .toString(),
              type: detailDataImage[pushBufferToImageModel.trans.toString()][2]
                  .toString(),
              long: detailDataImage[pushBufferToImageModel.trans.toString()]
                  [3]);
          provider.addTextMessage(textMessageModel);
        } else {
          String base64string = base64.encode(newList.cast<int>());
          var imageFireResult = "data:image/jpg;base64,$base64string";
          TextMessageModel textMessageModel = TextMessageModel(
              message: imageFireResult.toString(),
              sender: detailDataImage[pushBufferToImageModel.trans.toString()]
                      [0]
                  .toString(),
              hour: DateTime.now().hour.toString(),
              minute: DateTime.now().minute.toString(),
              channel: detailDataImage[pushBufferToImageModel.trans.toString()]
                      [1]
                  .toString(),
              type: detailDataImage[pushBufferToImageModel.trans.toString()][2]
                  .toString(),
              long: 1);
          provider.addTextMessage(textMessageModel);
        }

        SendSuccessModel sendSuccessModel = SendSuccessModel(
            address: pushBufferToImageModel.address,
            port: pushBufferToImageModel.port,
            trans: pushBufferToImageModel.trans);
        sendSuccess(sendSuccessModel, context);
        detailDataImage.remove(pushBufferToImageModel.trans.toString());
        missingIndex.remove(pushBufferToImageModel.trans);
        dataArr.remove(pushBufferToImageModel.trans);
        dataArrCheck.remove(pushBufferToImageModel.trans);
        checkTimeoutIndex.remove(pushBufferToImageModel.trans);
        checkTimeout.remove(pushBufferToImageModel.trans);
        GetTotalModel getTotalModel = GetTotalModel(
            trans: pushBufferToImageModel.trans,
            total: pushBufferToImageModel.total,
            address: pushBufferToImageModel.address,
            port: pushBufferToImageModel.port);
        waitTimeOutToCheck(getTotalModel, context);
      } else {
        // print("confirm To send...");
        confirmToSend(pushBufferToImageModel, context);
      }
    } else {
      refundData(pushBufferToImageModel, context);
    }
  }

  sendSuccess(SendSuccessModel sendSuccessModel, BuildContext context) {
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    pvdConnect.sendSuccess(sendSuccessModel);
  }

  refundData(GetTotalModel getTotalModel, BuildContext context) {
    print("refun");
    var pvdConnect =
        Provider.of<ConnectSocketUDPProvider>(context, listen: false);
    RefunDataModel refunDataModel = RefunDataModel(
        message: missingIndex[getTotalModel.trans],
        total: 1,
        round: 1,
        sumData: missingIndex[getTotalModel.trans].length,
        address: getTotalModel.address,
        port: getTotalModel.port,
        trans: getTotalModel.trans,
        type: 'IMAGE');
    pvdConnect.refundData(refunDataModel);
    checkTimeout.addAll({getTotalModel.trans: getTotalModel});
    waitTimeOutToCheck(getTotalModel, context);
  }

  removeAndAdds(PushBufferToImageModel pushBufferToImageModel) {
    var result = dataArr[pushBufferToImageModel.trans]
        .remove(pushBufferToImageModel.index.toString());
    if (result == true) {
      dataArr[pushBufferToImageModel.trans].insert(pushBufferToImageModel.index,
          pushBufferToImageModel.message.toString());
    }
  }

  removeDataToCheck(PushBufferToImageModel pushBufferToImageModel) {
    var result = missingIndex[pushBufferToImageModel.trans]
        .remove(pushBufferToImageModel.index);
    return result;
  }

  void addDataToCheck(int start, end, var trans) {
    for (var i = start; i < end; i++) {
      missingIndex[trans].add(i);
    }
  }

  void genData(GetTotalModel sendTotalModel) {
    dataArr.addAll({sendTotalModel.trans: []});
    for (var i = 0; i < totalToCheck[sendTotalModel.trans]; i++) {
      dataArr[sendTotalModel.trans].add(i.toString());
    }
  }

  Future<Null> waitTimeOutToCheck(
      GetTotalModel getTotalModel, BuildContext context) async {
    timeOut = Timer(Duration(seconds: 2), () {
      // print(dataArr[model.trans]);
      for (var i = 0; i < checkTimeoutIndex.length; i++) {
        // GetTotalModel model = checkTimeout[checkTimeoutIndex[i]];
        if (checkTimeout != null || checkTimeout.length > 0) {
          convertToImage(checkTimeout[checkTimeoutIndex[i]], context);
          // convertToImage(getTotalModel);
          print('convert');
        } else {
          print('cnacel');
          timeOut.cancel();
        }
      }
    });
  }

  resendData(GetResendDataModel getResendDataModel, BuildContext context) {
    if (dataArr[getResendDataModel.trans] != null) {
      if (getResendDataModel.message.length == getResendDataModel.sumData) {
        PushBufferToImageModel pushBufferToImageModel = PushBufferToImageModel(
            message: getResendDataModel.message,
            index: getResendDataModel.index,
            total: getResendDataModel.total,
            round: getResendDataModel.round,
            sumData: getResendDataModel.sumData,
            address: getResendDataModel.address,
            end: 0,
            port: getResendDataModel.port,
            start: 0,
            trans: getResendDataModel.trans);
        var resultRemove = removeDataToCheck(pushBufferToImageModel);
        if (resultRemove == true) {
          removeAndAdds(pushBufferToImageModel);
          dataArrCheck[getResendDataModel.trans].add(getResendDataModel.index);
        }
        if (getResendDataModel.round == getResendDataModel.total) {
          GetTotalModel getTotalModel = GetTotalModel(
              trans: getResendDataModel.trans,
              total: getResendDataModel.total,
              address: getResendDataModel.address,
              port: getResendDataModel.port);
          convertToImage(getTotalModel, context);
        }
      }
    }
  }

  var userList = [];

  getuserlist(List user) {
    userList = user;
    notifyListeners();
  }
}
