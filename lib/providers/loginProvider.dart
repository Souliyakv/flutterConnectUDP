import 'dart:convert';
import 'dart:io';

import 'package:demoudp/model/connectSocketUDP_model.dart';
import 'package:flutter/foundation.dart';

import '../services/enoumDataService.dart';
import '../widget/config.dart';

class LoginProvider with ChangeNotifier {
  List<String> user = [];
  late RawDatagramSocket socket;
  void login(LoginModel loginModel) {
    var loginData = {
      "data": {
        "userName": loginModel.username,
        "password": loginModel.password
      },
      "command": Ecommand().login,
    };
    this.socket.send(utf8.encode(jsonEncode(loginData)),
        InternetAddress("${IpAddress().ipAddress}"), 2222);
  }
  
}
