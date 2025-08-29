import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:brocast/objects/data_type.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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

class LocationViewChat extends StatefulWidget {
  final Broup? chat;

  const LocationViewChat({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  State<LocationViewChat> createState() => _LocationViewChatState();
}

class _LocationViewChatState extends State<LocationViewChat> {
  bool isLoading = false;
  bool showEmojiKeyboard = false;
  bool appendingCaption = false;
  bool isSending = false;
  FocusNode focusEmojiTextField = FocusNode();
  FocusNode focusCaptionField = FocusNode();
  TextEditingController captionMessageController = TextEditingController();
  TextEditingController broMessageController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Settings settings = Settings();
  final NavigationService _navigationService = locator<NavigationService>();
  late MapController mapController;
  LatLng _currentPosition = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    broMessageController.text = "🗺️";
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      mapController = MapController();
      LocationPermission permission;
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          return Future.error('Location Not Available');
        }
      } else {
        throw Exception('Error');
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      print("Current Location: $_currentPosition");
      mapController.move(_currentPosition, 14.0);
    } catch (e) {
      print('Error getting current location: $e');
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
        broMessageController.text = "🗺️";
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
      Uint8List mediaData = Uint8List(0);
      sendMediaMessage(mediaData, emojiMessage, textMessage);
    }
  }

  sendMediaMessage(Uint8List messageData, String message, String textMessage) async {
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
    if (formKey.currentState!.validate()) {
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

      AuthServiceSocialV15().sendMessage(widget.chat!.getBroupId(), message, messageTextMessage, messageData, DataType.audio.value, null).then((messageId) {
        setState(() {
          isSending = false;
        });
        if (messageId != null) {
          mes.isRead = 0;
          if (mes.messageId != messageId) {
            Storage().updateMessageId(mes.messageId, messageId, widget.chat!.getBroupId());
            mes.messageId = messageId;
          }
          setState(() {
            navigateToChat(context, settings, widget.chat!);
          });
        } else {
          Storage().deleteMessage(mes.messageId, widget.chat!.broupId);
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

  Widget mediaPreview() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: (MediaQuery.of(context).size.height / 5) * 3,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: _currentPosition,
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition,
                child: Icon(Icons.location_pin, color: Colors.red),
              ),
            ],
          ),
        ],
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
