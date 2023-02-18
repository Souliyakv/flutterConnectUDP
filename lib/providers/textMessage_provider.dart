import 'package:demoudp/model/textMessage_model.dart';
import 'package:flutter/foundation.dart';

class TextMessageProvider with ChangeNotifier {
  List<TextMessageModel> lTextMessages = [
    TextMessageModel(
        message:
            "https://img.freepik.com/free-photo/wide-angle-shot-single-tree-growing-clouded-sky-during-sunset-surrounded-by-grass_181624-22807.jpg",
        sender: "a",
        hour: "15",
        minute: "45",
        channel: "1",
        type: 'IMAGE'),
    TextMessageModel(
        message:
            "https://natureconservancy-h.assetsadobe.com/is/image/content/dam/tnc/nature/en/photos/Zugpsitze_mountain.jpg?crop=0%2C176%2C3008%2C1654&wid=4000&hei=2200&scl=0.752",
        sender: "b",
        hour: "15",
        minute: "45",
        channel: "1",
        type: 'IMAGE'),
  ];

  List<TextMessageModel> getTextMessage() {
    return lTextMessages;
  }

  void addTextMessage(TextMessageModel messageData) {
    lTextMessages.insert(0, messageData);
    notifyListeners();
  }
}
