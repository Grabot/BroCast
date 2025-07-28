import 'dart:typed_data';

import 'package:brocast/utils/utils.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';

import '../../objects/broup.dart';
import '../../utils/settings.dart';
import '../chat_view/preview_page_chat/preview_page_chat.dart';

class CameraPage extends StatefulWidget {
  final bool changeAvatar;
  final Broup? chat;

  const CameraPage({
    Key? key,
    required this.changeAvatar,
    this.chat,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  bool isLoading = false;

  takePicture(Uint8List pictureBytes) async {
    if (!widget.changeAvatar) {
      isLoading = false;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              PreviewPageChat(
                fromGallery: false,
                chat: widget.chat,
                media: pictureBytes,
                dataType: 0,
              ),
        ),
      );
    } else {
      Navigator.of(context).pop(pictureBytes);
    }
  }

  takeVideo(Uint8List videoBytes) async {
    if (!widget.changeAvatar) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              PreviewPageChat(
                fromGallery: false,
                chat: widget.chat,
                media: videoBytes,
                dataType: 1,
              ),
        ),
      );
    } else {
      showToastMessage("can't set video as avatar");
    }
  }

  void backButtonFunctionality() {
    if (isLoading) {
      return;
    }
    if (widget.changeAvatar) {
      Navigator.of(context).pop();
    } else {
      navigateToChat(context, Settings(), widget.chat!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Colors.white,
              child: CameraAwesomeBuilder.custom(
                sensorConfig: SensorConfig.single(
                  sensor: Sensor.position(SensorPosition.back),
                  flashMode: FlashMode.auto,
                  aspectRatio: CameraAspectRatios.ratio_4_3,
                  zoom: 0.0,
                ),
                enablePhysicalButton: true,
                previewAlignment: Alignment.center,
                previewFit: CameraPreviewFit.contain,
                saveConfig: SaveConfig.photoAndVideo(
                  initialCaptureMode: CaptureMode.photo,
                  photoPathBuilder: null,
                  videoPathBuilder: null,
                  videoOptions: VideoOptions(
                    enableAudio: true,
                    ios: CupertinoVideoOptions(
                      fps: 10,
                    ),
                    android: AndroidVideoOptions(
                      bitrate: 6000000,
                      fallbackStrategy: QualityFallbackStrategy.lower,
                    ),
                  ),
                  exifPreferences: ExifPreferences(saveGPSLocation: false),
                ),
                builder: (cameraState, preview) {
                  return AwesomeCameraLayout(
                    state: cameraState,
                    topActions: AwesomeTopActions(
                        state: cameraState,
                        children: [
                          AwesomeFlashButton(state: cameraState),
                          if (cameraState is PhotoCameraState)
                            AwesomeAspectRatioButton(state: cameraState),
                          if (cameraState is PhotoCameraState)
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                backButtonFunctionality();
                              },
                            ),
                        ]
                    ),
                    bottomActions: AwesomeBottomActions(
                        state: cameraState,
                        right: Container()
                    ),
                  );
                },
                onMediaCaptureEvent: (event) async {
                  if (event.isPicture && !event.isVideo) {
                    if (event.status == MediaCaptureStatus.capturing) {
                      setState(() {
                        isLoading = true;
                      });
                    } else if (event.status == MediaCaptureStatus.success) {
                      event.captureRequest.when(
                        single: (single) async {
                          if (single.file != null) {
                            Uint8List bytes = await single.file!.readAsBytes();
                            takePicture(bytes);
                          }
                        },
                        multiple: (multiple) async {
                          multiple.fileBySensor.forEach((key, value) async {
                            if (value != null) {
                              Uint8List bytes = await value.readAsBytes();
                              // Navigator.of(context).pop(bytes);
                              // TODO: Handle multiple files?
                            }
                          });
                        },
                      );
                    }
                  } else if (!event.isPicture && event.isVideo) {
                    if (event.status == MediaCaptureStatus.capturing) {
                    } else if (event.status == MediaCaptureStatus.success) {
                      event.captureRequest.when(
                        single: (single) async {
                          if (single.file != null) {
                            Uint8List bytes = await single.file!.readAsBytes();
                            takeVideo(bytes);
                          }
                        },
                        multiple: (multiple) async {
                          multiple.fileBySensor.forEach((key, value) async {
                            if (value != null) {
                              Uint8List bytes = await value.readAsBytes();
                              // Navigator.of(context).pop(bytes);
                              // TODO: Handle multiple files?
                            }
                          });
                        },
                      );
                    }
                  }
                },
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (isLoading)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withValues(alpha: 0.2),
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
