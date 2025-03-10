import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../objects/broup.dart';
import '../../../utils/settings.dart';
import '../../../utils/socket_services.dart';
import '../../chat_view/chat_messaging.dart';


class PreviewPageChat  extends StatefulWidget {

  final bool isMe;
  final Broup? chat;
  final Image picture;
  final XFile pictureData;
  final String pictureName;

  const PreviewPageChat({
    Key? key,
    required this.isMe,
    required this.chat,
    required this.picture,
    required this.pictureData,
    required this.pictureName
  }) : super(key: key);

  @override
  State<PreviewPageChat> createState() => _PreviewPageChatState();
}

class _PreviewPageChatState extends State<PreviewPageChat> {

  bool showEmojiKeyboard = false;
  bool appendingCaption = false;

  FocusNode focusEmojiTextField = FocusNode();
  FocusNode focusCaptionField = FocusNode();

  TextEditingController captionMessageController = new TextEditingController();
  TextEditingController broMessageController = new TextEditingController();

  SocketServices socketServices = SocketServices();
  Settings settings = Settings();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    focusEmojiTextField.dispose();
    focusCaptionField.dispose();
    captionMessageController.dispose();
    broMessageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    broMessageController.text = "📸";
    socketServices.checkConnection();
    setState(() {});
  }

  appendCaptionMessage() {
    if (!appendingCaption) {
      focusCaptionField.requestFocus();
      if (broMessageController.text == "") {
        broMessageController.text = "📸";
      }
      setState(() {
        showEmojiKeyboard = false;
        appendingCaption = true;
      });
    } else {
      focusEmojiTextField.requestFocus();
      captionMessageController.text = "";
      setState(() {
        showEmojiKeyboard = true;
        appendingCaption = false;
      });
    }
  }

  exitPreviewMode() async {
    // await availableCameras().then((value) => Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (_) => CameraPage(
    //         chat: widget.chat,
    //         cameras: value
    //     ))));
  }

  sendImage() async {
    if (formKey.currentState!.validate()) {
      // var bytes = await widget.pictureData.readAsBytes();
      // String encoded = base64.encode(bytes);
      //
      // if (widget.chat.isBroup()) {
      //   socketServices.socket.emit(
      //     "message_broup",
      //     {
      //       // "bro_id": settings.getBroId(),
      //       "broup_id": widget.chat.id,
      //       "message": broMessageController.text,
      //       "text_message": captionMessageController.text,
      //       "message_data": encoded
      //     },
      //   );
      // } else {
      //   socketServices.socket.emit(
      //     "message",
      //     {
      //       // "bro_id": settings.getBroId(),
      //       "bros_bro_id": widget.chat.id,
      //       "message": broMessageController.text,
      //       "text_message": captionMessageController.text,
      //       "message_data": encoded
      //     },
      //   );
      // }
      // // After sending the image we go back to the message screen.
      // // If the server has received the image it will be send back
      // // and we will load it there again.
      // backToMessageScreen();
    }
  }

  backToMessageScreen() {
    if (widget.chat != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ChatMessaging(
                      key: UniqueKey(), chat: widget.chat!)));
    }
  }

  void onTapEmojiTextField() {
    if (!showEmojiKeyboard) {
      Timer(Duration(milliseconds: 100), () {
        setState(() {
          showEmojiKeyboard = true;
        });
      });
    }
  }

  onTapCaptionTextField() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
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
                  child: Container(
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
                            GestureDetector(
                              onTap: () {
                                appendCaptionMessage();
                              },
                              child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                      color: appendingCaption
                                          ? Colors.green
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(35)),
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(Icons.text_snippet,
                                      color: appendingCaption
                                          ? Colors.white
                                          : Color(0xFF616161))),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 15),
                                child: Form(
                                  key: formKey,
                                  child: TextFormField(
                                    focusNode: focusEmojiTextField,
                                    validator: (val) {
                                      if (val == null ||
                                          val.isEmpty ||
                                          val.trimRight().isEmpty) {
                                        return "Can't send an empty message";
                                      }
                                      if (widget.chat != null && widget.chat!.isRemoved()) {
                                        return "Can't send messages to a blocked bro";
                                      }
                                      return null;
                                    },
                                    onTap: () {
                                      onTapEmojiTextField();
                                    },
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    controller: broMessageController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                        hintText: "Emoji message...",
                                        hintStyle:
                                        TextStyle(color: Colors.white54),
                                        border: InputBorder.none),
                                    readOnly: true,
                                    showCursor: true,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
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
                  ),
                ),
                Container(
                    child: appendingCaption
                        ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6),
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
                                    onTap: () {
                                      onTapCaptionTextField();
                                    },
                                    focusNode: focusCaptionField,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    controller: captionMessageController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                        hintText: "Append text message...",
                                        hintStyle: TextStyle(
                                            color: Colors.white54),
                                        border: InputBorder.none),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        : Container())
              ]),
            ),
          ),
          ),
              Align(
                alignment: Alignment.bottomCenter,
                child: EmojiKeyboard(
                  emojiController: broMessageController,
                  emojiKeyboardHeight: 300,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: settings.getEmojiKeyboardDarkMode(),
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
                          exitPreviewMode();
                        },
                      )),
                  Spacer(),
                  Spacer(),
                ]
                )
            ),
          ),
        ]
      ),
      ),
    );
  }
}