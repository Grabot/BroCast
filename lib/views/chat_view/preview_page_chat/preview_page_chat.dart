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

class PreviewPageChat extends StatefulWidget {
  final bool fromGallery;
  final Broup chat;
  final File mediaFile;
  final int dataType;
  final String? messageBodyForward;
  final String? textMessageForward;

  const PreviewPageChat({
    Key? key,
    required this.fromGallery,
    required this.chat,
    required this.mediaFile,
    required this.dataType,
    this.messageBodyForward,
    this.textMessageForward,
  }) : super(key: key);

  @override
  State<PreviewPageChat> createState() => _PreviewPageChatState();
}

class _PreviewPageChatState extends State<PreviewPageChat> {
  bool showEmojiKeyboard = false;
  bool appendingCaption = false;
  bool isLoading = true;
  bool isSending = false;

  FocusNode focusEmojiTextField = FocusNode();
  FocusNode focusCaptionField = FocusNode();

  TextEditingController captionMessageController = TextEditingController();
  TextEditingController broMessageController = TextEditingController();

  SocketServices socketServices = SocketServices();
  Settings settings = Settings();

  final formKey = GlobalKey<FormState>();

  VideoPlayerController? _videoController;

  final NavigationService _navigationService = locator<NavigationService>();

  PlayerController? _playerController;
  bool isPausedAudio = true;

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
    broMessageController.text = "📸";

    if (widget.dataType == DataType.image.value) {
      broMessageController.text = "📸";
      setState(() {
        isLoading = false;
      });
    } else if (widget.dataType == DataType.video.value) {
      broMessageController.text = "🎥";
      _initializeVideo();
    } else if (widget.dataType == DataType.audio.value) {
      broMessageController.text = "🎤";
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAudio();
      });
    } else if (widget.dataType == DataType.gif.value) {
      broMessageController.text = "🖼️";
      setState(() {
        isLoading = false;
      });
    } else if (widget.dataType == DataType.other.value) {
      broMessageController.text = "📄";
      setState(() {
        isLoading = false;
      });
    }
    if (widget.messageBodyForward != null && widget.messageBodyForward != "") {
      broMessageController.text = widget.messageBodyForward!;
      setState(() {
        isLoading = false;
      });
    }
    if (widget.textMessageForward != null && widget.textMessageForward != "") {
      captionMessageController.text = widget.textMessageForward!;
      appendingCaption = true;
      setState(() {
        isLoading = false;
      });
    }

    setState(() {});
  }

  Future<void> _initializeAudio() async {
    _playerController = PlayerController();
    await _playerController!.preparePlayer(
      path: widget.mediaFile.path,
      volume: 1.0,
      shouldExtractWaveform: true,
      noOfSamples: MediaQuery.of(context).size.width ~/ 6,
    );
    _playerController!.setFinishMode(finishMode: FinishMode.loop);
    // not sure why but this seems to be necessary.
    await _playerController!.startPlayer();
    await _playerController!.pausePlayer();
    setState(() {
      _playRecording();
      isLoading = false;
    });
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(widget.mediaFile!)
      ..initialize().then((_) {
        _videoController?.setLooping(true);
        _videoController?.pause();
        setState(() {
          isLoading = false;
        });
      });
  }

  _pausePlaying() {
    if (_playerController != null) {
      _playerController!.pausePlayer();
      setState(() {
        isPausedAudio = true;
      });
    }
  }


  void _playRecording() async {
    if (_playerController != null) {
      _playerController!.startPlayer(forceRefresh: false);
      setState(() {
        isPausedAudio = false;
      });
    }
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
        if (widget.dataType == DataType.image.value) {
          broMessageController.text = "📸";
        } else if (widget.dataType == DataType.video.value) {
          broMessageController.text = "🎥";
        } else if (widget.dataType == DataType.audio.value) {
          broMessageController.text = "🎤";
        } else if (widget.dataType == DataType.gif.value) {
          broMessageController.text = "🖼️";
        } else if (widget.dataType == DataType.other.value) {
          broMessageController.text = "📄";
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

  goBackToCamera() {
    Navigator.pushReplacement(
      context, MaterialPageRoute(
        builder: (context) => CameraPage(
          key: UniqueKey(),
          chat: widget.chat,
          changeAvatar: false,
        )
    ),
    );
  }

  exitPreviewMode() async {
    navigateToChat(context, settings, widget.chat);
  }

  gifOrOther(String message, String? messageTextMessage, Message mes) async {
    if (widget.dataType == DataType.gif.value) {
      AuthServiceSocialV15().sendMessageGif(
          widget.chat.getBroupId(), message, messageTextMessage, mes.data!, null).then((
          messageId) async {
        setState(() {
          isSending = false; // Set sending state to false
        });
        if (messageId != null) {
          mes.isRead = 0;
          if (mes.messageId != messageId) {
            mes.messageId = messageId;
          }
          await Storage().addMessage(mes);
          setState(() {
            // Go back to the chat.
            navigateToChat(context, settings, widget.chat);
          });
          // message send
        } else {
          Storage().deleteMessage(mes.messageId, widget.chat.broupId);
          // The message was not sent, we remove it from the list
          showToastMessage("there was an issue sending the message");
          isLoading = false;
          widget.chat.messages.removeAt(0);
        }
        setState(() {
          widget.chat.sendingMessage = false;
        });
      });
    } else {
      // other
      AuthServiceSocialV15().sendMessageOther(
          widget.chat.getBroupId(), message, messageTextMessage, mes.data!, null).then((
          messageId) async {
        setState(() {
          isSending = false; // Set sending state to false
        });
        if (messageId != null) {
          mes.isRead = 0;
          if (mes.messageId != messageId) {
            mes.messageId = messageId;
          }
          await Storage().addMessage(mes);
          setState(() {
            // Go back to the chat.
            navigateToChat(context, settings, widget.chat);
          });
          // message send
        } else {
          Storage().deleteMessage(mes.messageId, widget.chat.broupId);
          // The message was not sent, we remove it from the list
          showToastMessage("there was an issue sending the message");
          isLoading = false;
          widget.chat.messages.removeAt(0);
        }
        setState(() {
          widget.chat.sendingMessage = false;
        });
      });
    }
  }

  sendMediaMessage(File messageFile, String message, String textMessage, int dataType) async {
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
          body: message,
          textMessage: messageTextMessage,
          timestamp: DateTime.now().toUtc().toString(),
          data: await saveMediaFile(messageFile, dataType),
          dataType: dataType,
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

      if ((dataType == DataType.gif.value || dataType == DataType.other.value) && mes.data != null) {
        gifOrOther(message, messageTextMessage, mes);
      } else {
        AuthServiceSocialV15().sendMessage(
            widget.chat.getBroupId(), message, messageTextMessage, mes.data, dataType, null).then((
            messageId) async {
          setState(() {
            isSending = false; // Set sending state to false
          });
          if (messageId != null) {
            mes.isRead = 0;
            if (mes.messageId != messageId) {
              mes.messageId = messageId;
            }
            await Storage().addMessage(mes);
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
  }

  sendMedia() async {
    if (formKey.currentState!.validate()) {
      String emojiMessage = broMessageController.text;
      String textMessage = captionMessageController.text;
      sendMediaMessage(widget.mediaFile, emojiMessage, textMessage, widget.dataType);
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

  Widget playButtons() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height/6,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.height/9,
                  height: MediaQuery.of(context).size.height/9,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      !isPausedAudio ? Icons.pause : Icons.play_arrow,
                      color:  Colors.white,
                      size: MediaQuery.of(context).size.height/18,
                    ),
                    onPressed: !isPausedAudio ? _pausePlaying : _playRecording,
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget mediaPreview() {
    if (widget.dataType == DataType.video.value) {
      return _videoController != null && _videoController!.value.isInitialized
          ? Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - (75 + MediaQuery.of(context).padding.bottom + 16 + 20) - 50 - 10,
            child: Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),
          Container(
            height: 10.0,
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.blueAccent,
                bufferedColor: Colors.blueAccent.withValues(alpha: 0.5),
                backgroundColor: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          ),
          Container(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      _videoController!.value.isPlaying
                          ? _videoController!.pause()
                          : _videoController!.play();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator());
    } else if (widget.dataType == DataType.image.value) {
      return Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            margin: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - (75 + MediaQuery.of(context).padding.bottom + 16 + 20),  // 75 is the height of the bottom area, 16 is padding and sizedboxes, 20 is margin top and bottom
            child: Image.file(
              widget.mediaFile,
              width: 1,
              height: 1,
              gaplessPlayback: true,
              fit: BoxFit.contain,  // show all of the available image
            ),
          ),
        ),
      );
    } else if (widget.dataType == DataType.audio.value) {
      if (_playerController == null) {
        return Container();
      } else {
        return Column(
          children: [
            AudioFileWaveforms(
              size: Size(MediaQuery.of(context).size.width - 20,
                  MediaQuery.of(context).size.height / 5),
              playerController: _playerController!,
              enableSeekGesture: true,
              waveformType: WaveformType.fitWidth,
              playerWaveStyle: PlayerWaveStyle(
                liveWaveColor: Colors.red,
                fixedWaveColor: Colors.grey,
                spacing: 6,
              ),
            ),
            SizedBox(height: 20),
            playButtons()
          ]
        );
      }
    } else if (widget.dataType == DataType.gif.value) {
      return Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            margin: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - (75 + MediaQuery.of(context).padding.bottom + 16 + 20),  // 75 is the height of the bottom area, 16 is padding and sizedboxes, 20 is margin top and bottom
            child: Image.file(
              widget.mediaFile,
              width: 1,
              height: 1,
              gaplessPlayback: true,
              fit: BoxFit.contain,  // show all of the available image
            ),
          ),
        ),
      );
    } else {
      // Other data types
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
                  Icons.insert_drive_file,
                  size: 100,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  widget.mediaFile.path.split('/').last,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
                                : mediaPreview(),
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
                                              sendMedia();
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
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(),
                        Spacer(),
                        Spacer(),
                        if (!widget.fromGallery)
                          IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            icon: Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () async {
                              if (!isSending) {
                                goBackToCamera();
                              }
                            },
                          ),
                      ],
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