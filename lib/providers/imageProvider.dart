import 'package:demoudp/model/imageModel.dart';
import 'package:flutter/foundation.dart';

class ChooseImageProvider with ChangeNotifier {
  var allImageToSend = {};
  List<int> allImageToSendKey = [];
  void addImageToSend(ChooseImageModel imageModel) {
    allImageToSendKey.add(imageModel.keyIndex);
    allImageToSend.addAll({imageModel.keyIndex: imageModel.sperate});
    print(allImageToSendKey.length);
    print(allImageToSend.length);
  }
}
