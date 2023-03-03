import 'dart:async';

import 'package:camera/camera.dart';
import 'package:demoudp/page/checkVideo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final String sender;
  final String channel;
  const CameraScreen({super.key, required this.channel, required this.sender});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isLoading = true;
  late CameraController _cameraController;
  bool _isRecording = false;
  bool _isSwitch = true;
  String recordingTime = '0:0';

  @override
  void initState() {
    super.initState();
    _initCamera(true);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  _initCamera(bool switchCamera) async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    final black = cameras.firstWhere(
        (cameras) => cameras.lensDirection == CameraLensDirection.back);
    if (switchCamera) {
      _cameraController = CameraController(front, ResolutionPreset.max);
      await _cameraController.initialize();
      setState(() => _isLoading = false);
    } else {
      _cameraController = CameraController(black, ResolutionPreset.max);
      await _cameraController.initialize();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.transparent,
        // body: CameraPreview(_cameraController),
        appBar: AppBar(
          centerTitle: true,
          title: _isRecording ? Text('${recordingTime}') : const Text(''),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              size: 45,
            ),
          ),
        ),
        bottomNavigationBar: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CameraPreview(_cameraController),
            Padding(
              padding: const EdgeInsets.all(25),
              child: _isRecording
                  ? FloatingActionButton(
                      backgroundColor: Colors.red,
                      child: Icon(_isRecording ? Icons.stop : Icons.circle),
                      onPressed: () {
                        _recordVideo();
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(type: FileType.video);
                            if (result!.files.single.path != null ||
                                result.files.single.path!.length > 0) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return CheckVideoScreen(
                                  videoAddress: result.files.single.path,
                                  sender: widget.sender,
                                  channel: widget.channel,
                                );
                              }));
                            }
                          },
                          child: const Icon(Icons.image),
                        ),
                        FloatingActionButton(
                          backgroundColor: Colors.red,
                          child: Icon(_isRecording ? Icons.stop : Icons.circle),
                          onPressed: () {
                            _recordVideo();
                          },
                        ),
                        FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              _isSwitch = !_isSwitch;
                            });
                            _initCamera(_isSwitch);
                          },
                          child: const Icon(Icons.cameraswitch_sharp),
                        )
                      ],
                    ),
            ),
          ],
        ),
      );
    }
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CheckVideoScreen(
            videoAddress: file.path, channel: '1', sender: 'b'),
      );
      Navigator.push(context, route);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
      recordTime();
    }
  }

  void recordTime() {
    int startTime = 0;
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      // var diff = DateTime.now().difference(startTime);
      setState(() {
        startTime = startTime + 1;
        recordingTime =
            '${startTime ~/ 3600}:${startTime ~/ 60}:${startTime % 60}';
      });
      // recordingTime =
      //     '${diff.inHours < 60 ? diff.inHours : 0}:${diff.inMinutes < 60 ? diff.inMinutes : 0}:${diff.inSeconds < 60 ? diff.inSeconds : 0}';

      if (!_isRecording) {
        t.cancel(); //cancel function calling
      }

      // setState(() {});
    });
  }
}
