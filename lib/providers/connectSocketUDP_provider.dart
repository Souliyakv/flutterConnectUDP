import 'dart:io';

import 'package:flutter/foundation.dart';

class ConnectSocketUDPProvider with ChangeNotifier {
  late RawDatagramSocket socket;
}