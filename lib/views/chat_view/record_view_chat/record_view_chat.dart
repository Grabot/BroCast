import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:brocast/objects/data_type.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../../objects/broup.dart';
import '../../../objects/me.dart';
import '../../../objects/message.dart';
import '../../../services/auth/v1_5/auth_service_social_v1_5.dart';
import '../../../utils/locator.dart';
import '../../../utils/navigation_service.dart';
import '../../../utils/settings.dart';
import '../../../utils/socket_services.dart';
import '../../../utils/storage.dart';
import '../../../utils/utils.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

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
  FocusNode focusEmojiTextField = FocusNode();
  FocusNode focusCaptionField = FocusNode();
  TextEditingController captionMessageController = TextEditingController();
  TextEditingController broMessageController = TextEditingController();
  SocketServices socketServices = SocketServices();
  Settings settings = Settings();

  final formKey = GlobalKey<FormState>();

  bool isRecording = false;
  bool isPaused = true;

  late final RecorderController _recorderController;
  late final PlayerController _playerController;
  String? _recordedAudioPath;

  final NavigationService _navigationService = locator<NavigationService>();

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

  sendMedia() async {
    if (formKey.currentState!.validate()) {
      String emojiMessage = broMessageController.text;
      String textMessage = captionMessageController.text;
      if (_recordedAudioPath != null) {
        Uint8List mediaData = Uint8List.fromList(File(_recordedAudioPath!).readAsBytesSync());
        sendMediaMessage(mediaData, emojiMessage, textMessage);
      }
    }
  }

  // TODO: change to file like with video?
  sendMediaMessage(Uint8List messageData, String message, String textMessage) async {
    setState(() {
      isSending = true; // Set sending state to true
    });
    if (widget.chat == null) {
      // You shouldn't get here if the chat is null
      return;
    }
    int meId = -1;
    int newMessageId = widget.chat!.lastMessageId + 1;
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
          data: await saveMediaData(messageData, DataType.audio.value),
          dataType: DataType.audio.value,
          info: false,
          broupId: widget.chat!.getBroupId()
      );
      mes.isRead = 2;
      setState(() {
        widget.chat!.messages.insert(0, mes);
      });
      setState(() {
        widget.chat!.sendingMessage = true;
      });
      await Storage().addMessage(mes);

      AuthServiceSocialV15().sendMessage(widget.chat!.getBroupId(), message, messageTextMessage, mes.data, DataType.audio.value, null).then((messageId) {
        setState(() {
          isSending = false; // Set sending state to false
        });
        if (messageId != null) {
          mes.isRead = 0;
          if (mes.messageId != messageId) {
            Storage().updateMessageId(mes.messageId, messageId, widget.chat!.getBroupId());
            mes.messageId = messageId;
          }
          setState(() {
            // Go back to the chat.
            navigateToChat(context, settings, widget.chat!);
          });
          // message send
        } else {
          Storage().deleteMessage(mes.messageId, widget.chat!.broupId);
          // The message was not sent, we remove it from the list
          showToastMessage("there was an issue sending the message");
          widget.chat!.messages.removeAt(0);
        }
        setState(() {
          widget.chat!.sendingMessage = false;
        });
      });
      broMessageController.clear();
      captionMessageController.clear();
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

  _pausePlaying() {
    _playerController.pausePlayer();
    setState(() {
      isPaused = true;
    });
  }

  Widget playOrPause() {
    return Container(
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
                !isPaused ? Icons.pause : Icons.play_arrow,
                color:  Colors.white,
                size: MediaQuery.of(context).size.height/18,
              ),
              onPressed: !isPaused ? _pausePlaying : _playRecording,
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget audioWaveForm() {
    if (_recordedAudioPath != null) {
      return AudioFileWaveforms(
        size: Size(MediaQuery.of(context).size.width-20, MediaQuery.of(context).size.height/5),
        playerController: _playerController,
        enableSeekGesture: true,
        waveformType: WaveformType.fitWidth,
        playerWaveStyle: PlayerWaveStyle(
          liveWaveColor: Colors.red,
          fixedWaveColor: Colors.grey,
          spacing: 6,
        ),
      );
    } else {
      return AudioWaveforms(
        size: Size(MediaQuery.of(context).size.width-20, MediaQuery.of(context).size.height/5),
        recorderController: _recorderController,
        waveStyle: WaveStyle(
          waveColor: Colors.red,
          extendWaveform: true,
          showMiddleLine: false,
        ),
      );
    }
  }

  Widget recordButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height/6,
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
                isRecording ? Icons.stop : Icons.mic,
                color:  Colors.white,
                size: MediaQuery.of(context).size.height/18,
              ),
              onPressed: isRecording ? _stopRecording : _startRecording,
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget playButtons() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height/6,
          child: playOrPause(),
        ),
        Container(
          height: MediaQuery.of(context).size.height/9,
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height/18,
                child: ElevatedButton(
                  onPressed: _resetRecording,
                  child: Icon(
                      color: Colors.red,
                      Icons.redo
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height/18,
                child: Text(
                  "Retry recording",
                  style: simpleTextStyle(),
                ),
              )
            ]
          ),
        ),
      ],
    );
  }

  Widget mediaInterface() {
    if (_recordedAudioPath != null) {
      // Playback mode
      return playButtons();
    } else {
      // Recording mode
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          recordButton(),
          SizedBox(width: 20),
          SizedBox(height: MediaQuery.of(context).size.height/9),
        ],
      );
    }
  }

  Widget mediaPreview() {
    return Column(
      children: [
        audioWaveForm(),
        SizedBox(height: 20),
        mediaInterface(),
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
      }
    } catch (e) {
      showToastMessage('Error starting recording: $e');
    }
  }

  void _stopRecording() async {
    try {
      String? path = await _recorderController.stop();
      if (path != null) {
        _recordedAudioPath = path;
        await _playerController.preparePlayer(
          path: _recordedAudioPath!,
          volume: 1.0,
          shouldExtractWaveform: true,
          noOfSamples: MediaQuery.of(context).size.width ~/ 6,
        );
        _playerController.setFinishMode(finishMode: FinishMode.loop);
        // not sure why but this seems to be necessary.
        await _playerController.startPlayer();
        await _playerController.pausePlayer();
        setState(() {
          isRecording = false;
        });
      }
    } catch (e) {
      showToastMessage('Error stopping recording: $e');
    }
  }

  Future<String?> _getPath() async {
    Directory tempDirectory = await getTemporaryDirectory();
    return "${tempDirectory.path}/recording.m4a";
  }

  void _playRecording() async {
    _playerController.startPlayer(forceRefresh: false);
    setState(() {
      isPaused = false;
    });
  }

  void _resetRecording() async {
    await _playerController.stopPlayer();
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
                                              key: formKey,
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
