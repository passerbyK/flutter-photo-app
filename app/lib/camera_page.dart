import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:test_app/display_page.dart';
import 'package:light/light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final String userID;
  final String cameraType;
  final List typeList;

  const CameraPage(
      {Key? key,
      this.cameras,
      this.userID = '0',
      this.cameraType = 'none',
      required this.typeList})
      : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String luxString = 'Unknown'; // get light sensor data
  late final Light _light;
  late List<CameraDescription> availableCamera;
  late StreamSubscription _subscription;
  String typePath = 'none';
  String textType = ' ';

  void onData(int luxValue) async {
    print("Lux value: $luxValue");
    setState(() {
      luxString = "$luxValue";
    });
  }

  void stopListening() {
    _subscription.cancel();
  }

  void startListening() {
    _light = Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  Future<void> initPlatformState() async {
    startListening();
  }

  late CameraController _cameraController;
  final bool _isRearCameraSelected = false;

  Future getAvailableCamera() async {
    availableCamera = await availableCameras();
  }

  @override
  void initState() {
    super.initState();
    // List availableCameraList = availableCamera;
    initCamera(widget.cameras!.last);
    initPlatformState();
    ScreenBrightness().setScreenBrightness(1);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }

  // take picture
  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      XFile picture = await _cameraController.takePicture();
      await _cameraController.setFlashMode(FlashMode.off);
      String luxOutput = luxString;
      String userID = widget.userID;

      // fix the bug of the mirror effect from the front camera:
      if (!_isRearCameraSelected) {
        List<int> imageBytes = await picture.readAsBytes();

        img.Image? originalImage = img.decodeImage(imageBytes);
        img.Image fixedImage = img.flipHorizontal(originalImage!);

        File file = File(picture.path);

        File fixedFile = await file.writeAsBytes(
          img.encodeJpg(fixedImage),
          flush: true,
        );
      }
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DisplayPage(
                  imagePath: picture,
                  luxString: luxOutput,
                  userID: userID,
                  type: widget.cameraType,
                )),
      );
    } on CameraException catch (e) {
      debugPrint("Error occured while taking a picture: $e");
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.max);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("Camera Error $e");
    }
  }

  String imageTypePath() {
    // 舌上
    if (widget.cameraType == widget.typeList[0]) {
      typePath = 'assets/images/tongue.png';
    }

    // 舌下
    else if (widget.cameraType == widget.typeList[1]) {
      typePath = 'assets/images/sublingual.png';
    }

    // 正臉
    else if (widget.cameraType == widget.typeList[2]) {
      typePath = 'assets/images/front_face.png';
    }

    // 左臉
    else if (widget.cameraType == widget.typeList[3]) {
      typePath = 'assets/images/left_face2.png';
    }

    // 右臉
    else if (widget.cameraType == widget.typeList[4]) {
      typePath = 'assets/images/right_face2.png';
    }

    return typePath;
  }

  String textInCameraPage() {
    // 左臉
    if (widget.cameraType == widget.typeList[3]) {
      textType = '請擺出 45 度左側臉';
    }

    // 右臉
    else if (widget.cameraType == widget.typeList[4]) {
      textType = '請擺出 45 度右側臉';
    }

    return textType;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 35, right: 35),
                alignment: Alignment.center,
                child: (_cameraController.value.isInitialized
                    ? CameraPreview(_cameraController)
                    : const Center(child: CircularProgressIndicator())),
              ),
              Image.asset(
                alignment: (widget.cameraType == widget.typeList[0] ||
                        widget.cameraType == widget.typeList[1])
                    ? const Alignment(0.0, 0.75)
                    : Alignment.center,
                imageTypePath(),
                height: (widget.cameraType == widget.typeList[0] ||
                        widget.cameraType == widget.typeList[1])
                    ? MediaQuery.of(context).size.height * 0.65
                    : MediaQuery.of(context).size.height,
                width: (widget.cameraType == widget.typeList[0] ||
                        widget.cameraType == widget.typeList[1])
                    ? MediaQuery.of(context).size.width * 0.65
                    : MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.3),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.08,
                child: Text(textInCameraPage(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                  onTap: takePicture), // take a piture when touching screen
            ],
          ),
        ),
      ),
    );
  }
}
