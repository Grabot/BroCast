import 'dart:io';

import 'package:brocast/utils/utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../objects/broup.dart';
import '../../utils/shared.dart';

class CameraPage extends StatefulWidget {
  final Broup? chat;
  final List<CameraDescription>? cameras;
  final bool isMe;

  const CameraPage({
    Key? key,
    required this.chat,
    required this.isMe,
    required this.cameras,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  int _flash = 0;
  File? image;

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize();
      setState(() {});
    } on CameraException catch (e) {
      showToastMessage("Camera error");
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? picture = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picture != null) {
        Uint8List imageBytes = await picture.readAsBytes();
        Navigator.of(context).pop(imageBytes);
      }
    } on PlatformException catch (e) {
      showToastMessage("Failed to pick image");
    }
  }

  void setFlash() {
    setState(() {
      _flash = (_flash + 1) % 3;
    });
    HelperFunction.setFlashConfiguration(_flash).then((_) {
      setState(() {});
    });
  }

  Future<void> takePicture() async {
    if (!_cameraController.value.isInitialized || _cameraController.value.isTakingPicture) {
      return;
    }
    try {
      final FlashMode flashMode = _flash == 0 ? FlashMode.off : _flash == 1 ? FlashMode.always : FlashMode.auto;
      await _cameraController.setFlashMode(flashMode);
      await _cameraController.setFocusMode(FocusMode.locked);
      await _cameraController.setExposureMode(ExposureMode.locked);
      final XFile picture = await _cameraController.takePicture();
      await _cameraController.setFocusMode(FocusMode.auto);
      await _cameraController.setExposureMode(ExposureMode.auto);
      Uint8List imageBytes = await picture.readAsBytes();
      Navigator.of(context).pop(imageBytes);
    } on CameraException catch (e) {
      showToastMessage('Error occurred while taking picture');
    }
  }

  void exitCameraMode() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (_cameraController.value.isInitialized)
              CameraPreview(_cameraController)
            else
              Center(child: CircularProgressIndicator()),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: BoxDecoration(color: Colors.transparent),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: Icon(Icons.dangerous_outlined, color: Colors.white),
                        onPressed: exitCameraMode,
                      ),
                    ),
                    Spacer(),
                    Expanded(
                      child: IconButton(
                        iconSize: 20,
                        icon: Icon(
                          _flash == 0 ? Icons.flash_off : _flash == 1 ? Icons.flash_on : Icons.flash_auto,
                          color: Colors.white,
                        ),
                        onPressed: setFlash,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: BoxDecoration(color: Colors.transparent),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: Icon(
                          _isRearCameraSelected ? Icons.cameraswitch_rounded : Icons.cameraswitch_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() => _isRearCameraSelected = !_isRearCameraSelected);
                          initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: takePicture,
                        iconSize: 40,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: Icon(Icons.circle_outlined, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: Icon(Icons.image, color: Colors.white),
                        onPressed: pickImage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
