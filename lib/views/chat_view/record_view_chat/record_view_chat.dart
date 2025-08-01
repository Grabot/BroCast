import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import '../../../objects/broup.dart';
import '../../../objects/me.dart';
import '../../../objects/message.dart';
import '../../../services/auth/v1_5/auth_service_social_v1_5.dart';
import '../../../utils/locator.dart';
import '../../../utils/navigation_service.dart';
import '../../../utils/settings.dart';
import '../../../utils/socket_services.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

import '../../../utils/utils.dart';

class RecordViewChat extends StatefulWidget {
  final Broup? chat;

  const RecordViewChat({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  State<RecordViewChat> createState() => _RecordViewChatState();
}

class _RecordViewChatState extends State<RecordViewChat> {
  bool isLoading = false;
  bool showEmojiKeyboard = false;
  bool appendingCaption = false;
  bool isSending = false;
  bool isRecording = false;

  FocusNode focusEmojiTextField = FocusNode();
  FocusNode focusCaptionField = FocusNode();

  TextEditingController captionMessageController = TextEditingController();
  TextEditingController broMessageController = TextEditingController();

  SocketServices socketServices = SocketServices();
  Settings settings = Settings();

  // final formAudioKey = GlobalKey<FormState>();

  final NavigationService _navigationService = locator<NavigationService>();

  late final RecorderController _recorderController;
  late final PlayerController _playerController;
  String? _recordedAudioPath;

  @override
  void initState() {
    super.initState();
    broMessageController.text = "🎤";

    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;


    _playerController = PlayerController();
    setState(() {});
  }

  @override
  void dispose() {
    focusEmojiTextField.dispose();
    focusCaptionField.dispose();
    captionMessageController.dispose();
    broMessageController.dispose();
    _recorderController.dispose();
    _playerController.dispose();
    super.dispose();
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
        broMessageController.text = "🎤";
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
    if (widget.chat != null) {
      navigateToChat(context, settings, widget.chat!);
    }
  }

  sendMediaMessage(Uint8List messageData, String message, String textMessage, int dataType) async {
    setState(() {
      isSending = true;
    });
    if (widget.chat == null) {
      return;
    }
    int meId = -1;
    int newMessageId = widget.chat!.lastMessageId + 1;
    Me? me = settings.getMe();
    if (me == null) {
      showToastMessage("we had an issues getting your user information. Please log in again.");
      _navigationService.navigateTo(routes.SignInRoute);
      return;
    } else {
      meId = me.getId();
    }
    String? messageTextMessage;
    if (textMessage != "") {
      messageTextMessage = textMessage;
    }
    // TODO: fix
    // if (formAudioKey.currentState!.validate()) {
    //   Message mes = Message(
    //       messageId: newMessageId,
    //       senderId: meId,
    //       body: message,
    //       textMessage: messageTextMessage,
    //       timestamp: DateTime.now().toUtc().toString(),
    //       data: await saveMediaData(messageData, dataType),
    //       dataType: dataType,
    //       info: false,
    //       broupId: widget.chat!.getBroupId()
    //   );
    //   mes.isRead = 2;
    //   setState(() {
    //     widget.chat!.messages.insert(0, mes);
    //   });
    //   AuthServiceSocialV15().sendMessage(widget.chat!.getBroupId(), message, messageTextMessage, messageData, dataType, null).then((value) {
    //     setState(() {
    //       isSending = false;
    //     });
    //     if (value) {
    //       setState(() {
    //         mes.isRead = 0;
    //         navigateToChat(context, settings, widget.chat!);
    //       });
    //     } else {
    //       showToastMessage("there was an issue sending the message");
    //       widget.chat!.messages.removeAt(0);
    //     }
    //   });
    //   broMessageController.clear();
    //   captionMessageController.clear();
    // }
  }

  sendMedia() async {
    // TODO: Fix
    // if (formAudioKey.currentState!.validate()) {
    //   String emojiMessage = broMessageController.text;
    //   String textMessage = captionMessageController.text;
    //   Uint8List recordAudioTemp = Uint8List(0);
    //   sendMediaMessage(recordAudioTemp, emojiMessage, textMessage, 3);
    // }
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

  Widget mediaPreview() {
    return Column(
      children: [
        if (_recordedAudioPath != null)
          AudioFileWaveforms(
            size: Size(MediaQuery.of(context).size.width, 100),
            playerController: _playerController,
            enableSeekGesture: true, // Allows seeking through the audio by interacting with the waveform
            waveformType: WaveformType.fitWidth, // Adjust based on your needs
            playerWaveStyle: const PlayerWaveStyle(
              liveWaveColor: Colors.blue,
              fixedWaveColor: Colors.grey,
              spacing: 6,
            ),
          )
        else
          AudioWaveforms(
            size: Size(MediaQuery.of(context).size.width, 100),
            recorderController: _recorderController,
            waveStyle: WaveStyle(
              waveColor: Colors.blue,
              extendWaveform: true,
              showMiddleLine: false,
            ),
          ),
        SizedBox(height: 20),
        if (_recordedAudioPath != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _playRecording,
                child: Text('Play Recording'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _stopPlaying,
                child: Text('Stop Playing'),
              ),
            ],
          )
        else
          ElevatedButton(
            onPressed: isRecording ? _stopRecording : _startRecording,
            child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
          ),
        if (_recordedAudioPath != null)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _playRecording,
                    child: Text('Play Recording'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _stopPlaying,
                    child: Text('Stop Playing'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetRecording,
                child: Text('Record Again'),
              ),
            ],
          )
        else
          ElevatedButton(
            onPressed: isRecording ? _stopRecording : _startRecording,
            child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
          ),
      ],
    );
  }


  void _startRecording() async {
    try {
      String? path = await _getPath();
      if (path != null) {
        await _recorderController.record(path: path);
        setState(() {
          isRecording = true;
        });
      } else {
        print('Error: Could not get path for recording.');
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  void _stopRecording() async {
    try {
      String? path = await _recorderController.stop();
      if (path != null) {
        setState(() {
          isRecording = false;
          _recordedAudioPath = path;
        });
      } else {
        print('Error: Could not stop recording.');
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<String?> _getPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/audio.wav';
  }

  void _playRecording() async {
    // Set the finish mode before starting the player
    _playerController.setFinishMode(finishMode: FinishMode.stop);

    // Start the player
    await _playerController.preparePlayer(path: _recordedAudioPath!);
    await _playerController.startPlayer();
  }

  void _stopPlaying() async {
    await _playerController.stopPlayer();
  }

  void _resetRecording() {
    setState(() {
      _recordedAudioPath = null;
    });
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
                                ? Center(child: CircularProgressIndicator())
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
                                            appendCaptionMessage();
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
                                              child: TextFormField(
                                                focusNode: focusEmojiTextField,
                                                validator: (val) {
                                                  if (val == null || val.isEmpty || val.trimRight().isEmpty) {
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
                                            sendMedia();
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
                                                onTapCaptionTextField();
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
                        Expanded(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            icon: Icon(Icons.dangerous_outlined, color: Colors.white),
                            onPressed: () async {
                              exitPreviewMode();
                            },
                          ),
                        ),
                        Spacer(),
                        Spacer(),
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