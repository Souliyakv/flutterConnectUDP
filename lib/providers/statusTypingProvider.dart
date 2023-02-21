import 'package:demoudp/model/typingStatusModel.dart';
import 'package:flutter/foundation.dart';

class StatusTypingProvider with ChangeNotifier {
  var typingStatus = {};

  void addStatusTyping(GetTypingStatusModel status) {
    typingStatus.addAll({status.channel: status.status});
    print(typingStatus);
    notifyListeners();
  }
}
