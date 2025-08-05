import 'dart:async';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../../objects/broup.dart';
import '../../../utils/locator.dart';
import '../../../utils/navigation_service.dart';
import '../../../utils/settings.dart';
import '../../../utils/socket_services.dart';
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

  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

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
    _stopRecordingTimer();
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
    // TODO:
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
            enableSeekGesture: true,
            waveformType: WaveformType.fitWidth,
            playerWaveStyle: PlayerWaveStyle(
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
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _playRecording,
                    child: Icon(Icons.check),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _stopPlaying,
                    child: Icon(Icons.stop),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isRecording ? _stopRecording : _startRecording,
                child: Icon(isRecording ? Icons.stop : Icons.mic),
              ),
              SizedBox(width: 20),
              if (isRecording)
                ElevatedButton(
                  onPressed: _pauseRecording,
                  child: Icon(Icons.pause),
                ),
            ],
          ),
      ],
    );
  }

  void _pauseRecording() async {
    try {
      await _recorderController.pause();
      _stopRecordingTimer();
      setState(() {
        isRecording = false;
      });
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }

  void _startRecording() async {
    try {
      String? path = await _getPath();
      if (path != null) {
        await _recorderController.record(path: path);
        setState(() {
          isRecording = true;
          _recordingDuration = Duration.zero;
        });
        _startRecordingTimer();
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
        _stopRecordingTimer();
        _recordedAudioPath = path;
        _playerController.setFinishMode(finishMode: FinishMode.stop);
        await _playerController.preparePlayer(
          path: _recordedAudioPath!,
          volume: 1.0,
          noOfSamples: MediaQuery.of(context).size.width ~/ 6,
        );
        await _playerController.startPlayer();
        await _playerController.stopPlayer();
        setState(() {
          isRecording = false;
        });
      } else {
        print('Error: Could not stop recording.');
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
        _recordingDuration += Duration(seconds: 1);
    });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  Future<String?> _getPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/audio.wav';
  }

  void _playRecording() async {
    _playerController.setFinishMode(finishMode: FinishMode.stop);
    await _playerController.preparePlayer(
      path: _recordedAudioPath!,
      volume: 1.0,
      shouldExtractWaveform: false,
      noOfSamples: MediaQuery.of(context).size.width ~/ 6,
    );
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
