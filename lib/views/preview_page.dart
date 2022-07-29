import 'dart:ui';

import 'package:brocast/views/camera_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../objects/bro_bros.dart';
import '../objects/broup.dart';
import '../objects/chat.dart';
import '../services/settings.dart';
import '../services/socket_services.dart';
import 'bro_messaging.dart';
import 'broup_messaging.dart';

class PreviewPage  extends StatefulWidget {
  const PreviewPage({
    Key? key,
    required this.chat,
    required this.picture,
    required this.pictureData,
    required this.pictureName
  }) : super(key: key);

  final Chat chat;
  final Image picture;
  final XFile pictureData;
  final String pictureName;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {

  FocusNode focusEmojiTextField = FocusNode();

  TextEditingController captionMessageController = new TextEditingController();

  SocketServices socketServices = SocketServices();
  Settings settings = Settings();

  @override
  void dispose() {
    focusEmojiTextField.dispose();
    captionMessageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    socketServices.checkConnection();
    socketServices.addListener(socketListener);
    setState(() {});
  }

  socketListener() {

  }

  exitCameraMode() async {
    await availableCameras().then((value) => Navigator.push(context,
        MaterialPageRoute(builder: (_) => CameraPage(
            chat: widget.chat,
            cameras: value
        ))));
  }

  pressedCaptionField() {
    focusEmojiTextField.requestFocus();
   }

   sendImage() async {
    print("sending image with caption ${captionMessageController.text}");

    var bytes = await widget.pictureData.readAsBytes();
    // var decoder = Utf16BytesToCodeUnitsDecoder(bytes); // use le variant if no BOM
    // var string = String.fromCharCodes(decoder.decodeRest());
    String string = String.fromCharCodes(bytes);

    socketServices.socket.emit(
      "message",
      {
        "bro_id": settings.getBroId(),
        "bros_bro_id": widget.chat.id,
        "message": "📷",
        "text_message": captionMessageController.text,
        "message_data": string
      },
    );
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
        child: Stack(
        children:
        [
          Container(
          child: Column(
            children: [
          Expanded(
          child: SingleChildScrollView(
          reverse: true,
              child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(height: 20),
                widget.picture,
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Color(0x36FFFFFF),
                          borderRadius: BorderRadius.circular(35)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 15),
                              child: Form(
                                child: TextFormField(
                                  focusNode: focusEmojiTextField,
                                  onTap: () {
                                    pressedCaptionField();
                                  },
                                  controller: captionMessageController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      hintText: "Add a caption...",
                                      hintStyle:
                                      TextStyle(color: Colors.white54),
                                      border: InputBorder.none),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              sendImage();
                            },
                            child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    color: Color(0xFF34A843),
                                    borderRadius: BorderRadius.circular(35)),
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ]),
            ),
          ),
          ),
          ]
          ),
        ),
          Align(
              alignment: Alignment.topCenter,
    child: Container(
    height: MediaQuery.of(context).size.height * 0.15,
    decoration: const BoxDecoration(
    color: Colors.transparent),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 20,
            icon: Icon(
                Icons.dangerous_outlined,
                color: Colors.white),
            onPressed: () async {
              exitCameraMode();
            },
          )),
      Spacer(),
      Spacer(),
      ]
              )
          ),
          )
        ]
      ),
      ),
    );
  }
}