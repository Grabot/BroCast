import 'dart:async';
import 'dart:typed_data';

import 'package:brocast/services/auth/v1_5/auth_service_social_v1_5.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';

import '../../../objects/broup.dart';
import '../../../utils/settings.dart';
import '../../../utils/socket_services.dart';
import '../../objects/message.dart';
import '../../utils/utils.dart';


class PreviewPageChat extends StatefulWidget {

  final Broup chat;
  final Uint8List image;

  const PreviewPageChat({
    Key? key,
    required this.chat,
    required this.image
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
    setState(() {});
  }

  backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      exitPreviewMode();
    }
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
    Navigator.of(context).pop(null);
  }

  sendImageMessage(Uint8List messageData, String message, String textMessage) {
    String? messageTextMessage;
    if (textMessage != "") {
      messageTextMessage = textMessage;
    }
    if (formKey.currentState!.validate()) {
      Message mes = new Message(
        widget.chat.lastMessageId + 1,
        settings.getMe()!.getId(),
        message,
        messageTextMessage,
        DateTime.now().toUtc().toString(),
        null,
        false,
        widget.chat.getBroupId(),
      );
      mes.isRead = 2;
      setState(() {
        widget.chat.messages.insert(0, mes);
      });
      AuthServiceSocialV15().sendMessage(widget.chat.getBroupId(), message, messageTextMessage, messageData, null).then((value) {
        if (value) {
          setState(() {
            mes.isRead = 0;
            // Go back to the chat.
            Navigator.of(context).pop(null);
          });
          // message send
        } else {
          // The message was not sent, we remove it from the list
          showToastMessage("there was an issue sending the message");
        }
      });
      broMessageController.clear();
      captionMessageController.clear();
    }
  }

  sendImage() async {
    if (formKey.currentState!.validate()) {
      String emojiMessage = broMessageController.text;
      String textMessage = captionMessageController.text;
      sendImageMessage(widget.image, emojiMessage, textMessage);
    }
  }

  onTapEmojiTextField() {
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

  Widget imagePreview() {
    return Container(
      margin: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - (75 + MediaQuery.of(context).padding.bottom + 16 + 20),  // 75 is the height of the bottom area, 16 is padding and sizedboxes, 20 is margin top and bottom
      child: Image.memory(
        widget.image,
        width: 1,
        height: 1,
        gaplessPlayback: true,
        fit: BoxFit.contain,  // show all of the available image
      ),
    );
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
          children:
          [
            Container(
            child: Column(
              children: [
            Expanded(
            child: SingleChildScrollView(
            reverse: true,
                child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    imagePreview(),
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
                        ) : Container()
                      )
                  ]
                ),
              ),
            ),
            ),
                !showEmojiKeyboard ? SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ) : Container(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: EmojiKeyboard(
                      emojiController: broMessageController,
                      emojiKeyboardHeight: 350,
                      showEmojiKeyboard: showEmojiKeyboard,
                      darkMode: settings.getEmojiKeyboardDarkMode(),
                      emojiKeyboardAnimationDuration: const Duration(milliseconds: 200),
                  ),
                ),
              ]
            ),
          ),
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    decoration: const BoxDecoration(
                        color: Colors.transparent),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                )
                            ),
                        Spacer(),  // Spacers to align the close button properly
                        Spacer(),
                    ]
                  )
                ),
              ]
              ),
            ),
          ]
        ),
      ),
    );
  }
}