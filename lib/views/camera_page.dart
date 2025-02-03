// import 'dart:io';
//
// import 'package:brocast/views/preview_page.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:back_button_interceptor/back_button_interceptor.dart';
//
// import '../objects/bro_bros.dart';
// import '../objects/broup.dart';
// import '../objects/chat.dart';
// import '../utils/shared.dart';
// import 'bro_messaging.dart';
// import 'broup_messaging.dart';
//
// class CameraPage extends StatefulWidget {
//   const CameraPage({
//     Key?   key,
//     required this.chat,
//     required this.cameras
//   }) : super(key: key);
//
//   final Chat chat;
//   final List<CameraDescription>? cameras;
//
//   @override
//   State<CameraPage> createState() => _CameraPageState();
// }
//
// class _CameraPageState extends State<CameraPage> {
//   late CameraController _cameraController;
//   bool _isRearCameraSelected = true;
//   int _flash = 0;
//
//   File? image;
//
//   Future pickImage() async {
//     try {
//       XFile? picture = await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (picture != null) {
//
//         Image test = Image.file(File(picture.path), fit: BoxFit.cover, width: MediaQuery.of(context).size.width - 100);
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) =>
//                     PreviewPage(
//                       chat: widget.chat,
//                       picture: test,
//                       pictureData: picture,
//                       pictureName: picture.name,
//                     )));
//       } else {
//         print("image gallery error!");
//       }
//     } on PlatformException catch(e) {
//       print("failed to pick image: $e");
//     }
//   }
//
//   bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
//     exitCameraMode();
//     return false;
//   }
//
//   @override
//   void dispose() {
//     _cameraController.dispose();
//     BackButtonInterceptor.remove(myInterceptor);
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     BackButtonInterceptor.add(myInterceptor);
//
//     // HelperFunction.getFlashConfiguration().then((val) {
//     //   if (val != null) {
//     //     _flash = val;
//     //   }
//     // });
//
//     initCamera(widget.cameras![0]);
//   }
//
//   setFlash() {
//     _flash += 1;
//     if (_flash == 3) {
//       _flash = 0;
//     }
//     // HelperFunction.setFlashConfiguration(_flash).then((val) {
//     //   setState(() {
//     //   });
//     // });
//   }
//
//   Future takePicture() async {
//     if (!_cameraController.value.isInitialized) {
//       return null;
//     }
//     if (_cameraController.value.isTakingPicture) {
//       return null;
//     }
//     try {
//       FlashMode flashMode = FlashMode.auto;
//       if (_flash == 0) {
//         flashMode = FlashMode.off;
//       } else if (_flash == 1) {
//         flashMode = FlashMode.always;
//       }
//       await _cameraController.setFlashMode(flashMode);
//       XFile picture = await _cameraController.takePicture();
//
//       Image test = Image.file(File(picture.path), fit: BoxFit.cover, width: MediaQuery.of(context).size.width - 100);
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//               builder: (context) => PreviewPage(
//                 chat: widget.chat,
//                 picture: test,
//                 pictureData: picture,
//                 pictureName: picture.name,
//               )));
//
//     } on CameraException catch (e) {
//       debugPrint('Error occured while taking picture: $e');
//       return null;
//     }
//   }
//
//   Future initCamera(CameraDescription cameraDescription) async {
//     _cameraController =
//         CameraController(cameraDescription, ResolutionPreset.high);
//     try {
//       await _cameraController.initialize().then((_) {
//         if (!mounted) return;
//         setState(() {});
//       });
//     } on CameraException catch (e) {
//       debugPrint("camera error $e");
//     }
//   }
//
//   exitCameraMode() {
//     if (widget.chat.isBroup()) {
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//               builder: (context) =>
//                   BroupMessaging(key: UniqueKey(), chat: widget.chat as Broup)));
//     } else {
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//               builder: (context) =>
//                   BroMessaging(key: UniqueKey(), chat: widget.chat as BroBros)));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SafeArea(
//           child: Stack(
//               children: [
//             (_cameraController.value.isInitialized)
//                 ? _cameraController.buildPreview()
//                 : Container(
//                 color: Colors.black,
//                 child: const Center(child: CircularProgressIndicator())),
//             Align(
//               alignment: Alignment.topCenter,
//                 child: Container(
//                     height: MediaQuery.of(context).size.height * 0.15,
//                     decoration: const BoxDecoration(
//                         color: Colors.transparent),
//                     child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//                       Expanded(
//                           child: IconButton(
//                             padding: EdgeInsets.zero,
//                             iconSize: 20,
//                             icon: Icon(
//                                 Icons.dangerous_outlined,
//                                 color: Colors.white),
//                             onPressed: () {
//                               exitCameraMode();
//                             },
//                           )),
//                       Spacer(),
//                       Expanded(
//                           child: IconButton(
//                             iconSize: 20,
//                             icon: Icon(
//                                 _flash == 0 ? Icons.flash_off
//                                     : _flash == 1 ? Icons.flash_on
//                                     : Icons.flash_auto,
//                                 color: Colors.white),
//                             onPressed: () {
//                               setFlash();
//                             },
//                           )),
//                     ]),
//                 ),
//             ),
//             Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.15,
//                   decoration: const BoxDecoration(
//                       color: Colors.transparent),
//                   child:
//                   Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//                     Expanded(
//                         child: IconButton(
//                           padding: EdgeInsets.zero,
//                           iconSize: 20,
//                           icon: Icon(
//                               _isRearCameraSelected
//                                   ? Icons.cameraswitch_rounded
//                                   : Icons.cameraswitch_outlined,
//                               color: Colors.white),
//                           onPressed: () {
//                             setState(
//                                     () => _isRearCameraSelected = !_isRearCameraSelected);
//                             initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
//                           },
//                         )),
//                     Expanded(
//                         child: IconButton(
//                           onPressed: takePicture,
//                           iconSize: 40,
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                           icon: const Icon(Icons.circle_outlined, color: Colors.white),
//                         )),
//                     Expanded(
//                         child: IconButton(
//                           padding: EdgeInsets.zero,
//                           iconSize: 20,
//                           icon: Icon(
//                               Icons.image,
//                               color: Colors.white),
//                           onPressed: () {
//                             pickImage();
//                           },
//                         )),
//                   ]),
//                 )),
//           ]),
//         ));
//   }
// }