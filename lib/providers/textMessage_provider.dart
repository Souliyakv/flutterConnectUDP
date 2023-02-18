import 'package:demoudp/model/textMessage_model.dart';
import 'package:flutter/foundation.dart';

class TextMessageProvider with ChangeNotifier {
  List<TextMessageModel> lTextMessages = [];

  List<TextMessageModel> getTextMessage() {
    return lTextMessages;
  }

  void addTextMessage(TextMessageModel messageData) {
    lTextMessages.insert(0, messageData);
    notifyListeners();
  }
}
