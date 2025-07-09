import 'dart:io';
import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';

class CameraPage extends StatefulWidget {
  final bool isMe;

  const CameraPage({
    Key? key,
    required this.isMe,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {

  takePicture(Uint8List pictureBytes) async {
    Navigator.of(context).pop([pictureBytes, false]);
  }

  takeVideo(Uint8List videoBytes) async {
    Navigator.of(context).pop([videoBytes, true]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: CameraAwesomeBuilder.awesome(
          onMediaCaptureEvent: (event) async {
            if (event.isPicture && !event.isVideo) {
              if (event.status == MediaCaptureStatus.capturing) {
                print("currently capturing!");
              } else if (event.status == MediaCaptureStatus.success) {
                print("picture done!");
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
                print("currently capturing!");
              } else if (event.status == MediaCaptureStatus.success) {
                print("video done!");
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
          sensorConfig: SensorConfig.single(
            sensor: Sensor.position(SensorPosition.back),
            flashMode: FlashMode.auto,
            aspectRatio: CameraAspectRatios.ratio_4_3,
            zoom: 0.0,
          ),
          enablePhysicalButton: true,
          previewAlignment: Alignment.center,
          previewFit: CameraPreviewFit.contain,
          availableFilters: awesomePresetFiltersList,
        ),
      ),
    );
  }
}
