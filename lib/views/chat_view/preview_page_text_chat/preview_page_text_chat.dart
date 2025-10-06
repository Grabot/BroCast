import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../objects/broup.dart';
import '../../../objects/data_type.dart';
import '../../../objects/me.dart';
import '../../../objects/message.dart';
import '../../../services/auth/v1_5/auth_service_social_v1_5.dart';
import '../../../utils/locator.dart';
import '../../../utils/navigation_service.dart';
import '../../../utils/settings.dart';
import '../../../utils/socket_services.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

import '../../../utils/storage.dart';
import '../../../utils/utils.dart';
import '../../camera_page/camera_page.dart';

class PreviewPageTextChat extends StatefulWidget {
  final Broup chat;
  final String? shareText;
  final String? shareTextBody;
  final bool url;

  const PreviewPageTextChat({
    Key? key,
    required this.chat,
    required this.shareText,
    required this.shareTextBody,
    required this.url,
  }) : super(key: key);

  @override
  State<PreviewPageTextChat> createState() => _PreviewPageTextChatState();
}

class _PreviewPageTextChatState extends State<PreviewPageTextChat> {
  bool showEmojiKeyboard = false;
  bool appendingCaption = true;
  bool isLoading = false;
  bool isSending = false;

  FocusNode focusEmojiTextField = FocusNode();
  FocusNode focusCaptionField = FocusNode();

  TextEditingController captionMessageController = TextEditingController();
  TextEditingController broMessageController = TextEditingController();

  SocketServices socketServices = SocketServices();
  Settings settings = Settings();

  final formKey = GlobalKey<FormState>();

  VideoPlayerController? _videoController;

  PlayerController? _playerController;
  bool isPausedAudio = true;

  final NavigationService _navigationService = locator<NavigationService>();

  @override
  void dispose() {
    focusEmojiTextField.dispose();
    focusCaptionField.dispose();
    captionMessageController.dispose();
    broMessageController.dispose();
    _videoController?.dispose();
    _playerController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.shareTextBody != null) {
      broMessageController.text = widget.shareTextBody!;
    } else {
      if (widget.url) {
        broMessageController.text = "📤🤝🔗";
      } else {
        broMessageController.text = "📤🤝";
      }
    }
    if (widget.shareText != null && widget.shareText != "") {
      captionMessageController.text = widget.shareText!;
    } else {
      appendingCaption = false;
    }

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
        if (widget.shareTextBody != null) {
          broMessageController.text = widget.shareTextBody!;
        } else {
          if (widget.url) {
            broMessageController.text = "📤🤝🔗";
          } else {
            broMessageController.text = "📤🤝";
          }
        }
      }
      if (captionMessageController.text == "") {
        if (widget.shareText != null && widget.shareText != "") {
          captionMessageController.text = widget.shareText!;
        }
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
    navigateToChat(context, settings, widget.chat);
  }

  sendShareMessage(String emojiMessage, String? textMessage) async {
    setState(() {
      showEmojiKeyboard = false;
      isSending = true; // Set sending state to true
    });
    int meId = -1;
    int newMessageId = widget.chat.lastMessageId + 1;
    Me? me = settings.getMe();
    if (me == null) {
      showToastMessage("we had an issues getting your user information. Please log in again.");
      // This needs to be filled if the user is logged in, if it's not we send the bro back to the login
      _navigationService.navigateTo(routes.SignInRoute);
      return;
    } else {
      meId = me.getId();
    }
    String? messageTextMessage;
    if (textMessage != "") {
      messageTextMessage = textMessage;
    }
    if (formKey.currentState!.validate()) {
      // We will save all the data already on the message. But not yet store it in the db.
      // We will receive it again via the socket and we will update some server information
      // On this object and then store it in the db.
      Message mes = Message(
          messageId: newMessageId,
          senderId: meId,
          body: emojiMessage,
          textMessage: messageTextMessage,
          timestamp: DateTime.now().toUtc().toString(),
          data: null,
          dataType: null,
          info: false,
          broupId: widget.chat.getBroupId()
      );
      mes.isRead = 2;
      setState(() {
        widget.chat.messages.insert(0, mes);
      });
      setState(() {
        widget.chat.sendingMessage = true;
      });
      AuthServiceSocialV15().sendMessage(widget.chat.getBroupId(), emojiMessage, messageTextMessage, null, null, null).then((messageId) async {
        setState(() {
          isSending = false;
        });
        if (messageId != null) {
          mes.isRead = 0;
          if (mes.messageId != messageId) {
            mes.messageId = messageId;
            await Storage().addMessage(mes);
          }
          setState(() {
            // Go back to the chat.
            navigateToChat(context, settings, widget.chat);
          });
          // message send
        } else {
          Storage().deleteMessage(mes.messageId, widget.chat.broupId);
          // The message was not sent, we remove it from the list
          showToastMessage("there was an issue sending the message");
          widget.chat.messages.removeAt(0);
          isLoading = false;
        }
        setState(() {
          widget.chat.sendingMessage = false;
        });
      });
    }
    broMessageController.clear();
    captionMessageController.clear();
  }

  sendMessage() async {
    if (formKey.currentState!.validate()) {
      String emojiMessage = broMessageController.text;
      String textMessage = captionMessageController.text;
      sendShareMessage(emojiMessage, textMessage);
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

  PreferredSize appBarChat() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Ink(
        color: widget.chat.getColor(),
        child: InkWell(
          child: AppBar(
              leading: IconButton(
                  icon:
                  Icon(Icons.arrow_back, color: getTextColor(widget.chat.getColor())),
                  onPressed: () {
                    if (!isSending) {
                      backButtonFunctionality();
                    } else {
                      showToastMessage("Please wait until the file is sent");
                    }
                  }),
              backgroundColor: Colors.transparent,
              title: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    child: avatarBox(50, 50, widget.chat.getAvatar()),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Container(
                        alignment: Alignment.centerLeft,
                        color: Colors.transparent,
                        child: Text("Send to: " + widget.chat.getBroupNameOrAlias(),
                          style: TextStyle(
                              color: getTextColor(widget.chat.getColor()),
                              fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                    ),
                  )
                ],
              ),
              actions: [
                PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert, color: getTextColor(widget.chat.getColor())),
                  onSelected: (item) => onSelectChat(context, item),
                  itemBuilder: (context) => [
                    PopupMenuItem<int>(value: 0, child: Text("Back to Chat")),
                  ]
                )
              ]),
        ),
      ),
    );
  }

  void onSelectChat(BuildContext context, int item) {
    switch (item) {
      case 0:
        if (!isSending) {
          backButtonFunctionality();
        } else {
          showToastMessage("Please wait until the file is sent");
        }
        break;
    }
  }

  Widget sharePreview() {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          margin: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - (75 + MediaQuery.of(context).padding.bottom + 16 + 20),  // 75 is the height of the bottom area, 16 is padding and sizedboxes, 20 is margin top and bottom
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.shareTextBody != null ? Icons.forward : Icons.share,
                size: 100,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          if (!isSending) {
            backButtonFunctionality();
          } else {
            showToastMessage("Please wait while the message is being sent");
          }
        }
      },
      child: Scaffold(
        appBar: appBarChat(),
        body: Stack(
          children: [
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
                            isLoading
                                ? Center(child: CircularProgressIndicator()) // Show progress indicator while loading
                                : sharePreview(),
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
                                      borderRadius: BorderRadius.circular(35),
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (!isSending) {
                                              appendCaptionMessage();
                                            }
                                          },
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                              color: appendingCaption ? Colors.green : Colors.grey,
                                              borderRadius: BorderRadius.circular(35),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 6),
                                            child: Icon(
                                              Icons.text_snippet,
                                              color: appendingCaption ? Colors.white : Color(0xFF616161),
                                            ),
                                          ),
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
                                                  if (val == null || val.isEmpty || val.trimRight().isEmpty) {
                                                    return "Can't send an empty message";
                                                  }
                                                  if (widget.chat.isRemoved()) {
                                                    return "Can't send messages to a blocked bro";
                                                  }
                                                  return null;
                                                },
                                                onTap: () {
                                                  if (!isSending) {
                                                    onTapEmojiTextField();
                                                  }
                                                },
                                                keyboardType: TextInputType.multiline,
                                                maxLines: null,
                                                controller: broMessageController,
                                                style: TextStyle(color: Colors.white),
                                                decoration: InputDecoration(
                                                  hintText: "Emoji message...",
                                                  hintStyle: TextStyle(color: Colors.white54),
                                                  border: InputBorder.none,
                                                ),
                                                readOnly: true,
                                                showCursor: true,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        GestureDetector(
                                          onTap: () {
                                            if (!isSending) {
                                              sendMessage();
                                            }
                                          },
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF34A843),
                                              borderRadius: BorderRadius.circular(35),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 6),
                                            child: Icon(
                                              Icons.send,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
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
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Form(
                                            child: TextFormField(
                                              onTap: () {
                                                if (!isSending) {
                                                  onTapCaptionTextField();
                                                }
                                              },
                                              focusNode: focusCaptionField,
                                              keyboardType: TextInputType.multiline,
                                              maxLines: null,
                                              controller: captionMessageController,
                                              style: TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                hintText: "Append text message...",
                                                hintStyle: TextStyle(color: Colors.white54),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  !showEmojiKeyboard
                      ? SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                      : Container(),
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
                ],
              ),
            ),
            if (isSending)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}