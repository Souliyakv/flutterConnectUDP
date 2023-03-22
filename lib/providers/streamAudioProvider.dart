import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

class StreamAudioProvider with ChangeNotifier {
  // final player = AudioPlayer();
  late List<int> byte = [];
  FlutterSoundPlayer _soundPlayer = FlutterSoundPlayer();
  getBufferStream(var message) async {
    byte = message.cast<int>();
    print(byte);

    // await _soundPlayer.feedFromStream(Uint8List.fromList(byte));
    // _soundPlayer.foodSink!.add(FoodData(Uint8List.fromList(byte)));

    print("playin gstatus is :${_soundPlayer.isPlaying}");
  }

  startStream() async {
    await _soundPlayer.openPlayer(enableVoiceProcessing: true);
    await _soundPlayer.startPlayerFromStream(
        codec: Codec.pcm16, numChannels: 1, sampleRate: 16000);

    // _soundPlayer.openPlayer(enableVoiceProcessing: true);
    // await _soundPlayer.startPlayer(fromDataBuffer: Uint8List.fromList(byte));
    // await player.setAudioSource(MyCustomSource(byte));
    // player.play();
  }
}

// class MyCustomSource extends StreamAudioSource {
//   final List<int> bytes;
//   MyCustomSource(this.bytes);

//   @override
//   Future<StreamAudioResponse> request([int? start, int? end]) async {
//     start ??= 0;
//     end ??= bytes.length;
//     print(bytes);
//     return StreamAudioResponse(
//         sourceLength: bytes.length,
//         contentLength: end - start,
//         offset: start,
//         stream: Stream.value(bytes.sublist(start, end)),
//         contentType: 'audio/wav');
//   }
// }
