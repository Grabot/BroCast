import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:brocast/objects/data_type.dart';
import 'package:dio/dio.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../../constants/base_url.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


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
  bool isLoading = true;
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

  late GoogleMapController mapController;

  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Dio _dio = Dio();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getLocation();
    broMessageController.text = "🗺️";
  }

  @override
  void dispose() {
    super.dispose();
  }

  getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    setState(() {
      _currentPosition = location;
      isLoading = false;
      // TODO: Fetch nearby places here not working
      _fetchNearbyPlaces(_currentPosition!);
    });
  }

  Future<void> _fetchNearbyPlaces(LatLng location) async {
    try {
      print("Fetching nearby places...");
      final response = await _dio.get(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json",
        queryParameters: {
          'location': '${location.latitude},${location.longitude}',
          'radius': 1000,
          'type': 'restaurant',
          'key': MAPS_API_KEY,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;

        setState(() {
          _markers.clear();
          for (var place in results) {
            final lat = place['geometry']['location']['lat'];
            final lng = place['geometry']['location']['lng'];
            final name = place['name'];
            final markerId = place['place_id'];

            print("Marker ID: $markerId");
            print("Name: $name");

            _markers.add(
              Marker(
                markerId: MarkerId(markerId),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(title: name),
                onTap: () => _onMarkerTapped(LatLng(lat, lng), name),
              ),
            );
          }
        });
      } else {
        showToastMessage("Failed to fetch places");
      }
    } on DioException catch (e) {
      showToastMessage("Error fetching places: ${e.message}");
    }
  }

  Future<void> _onMarkerTapped(LatLng position, String? placeName) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "${place.street}, ${place.locality}, ${place.country}";
        _showPlaceInfo(placeName ?? "Unknown", address);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not get address: $e")),
      );
    }
  }


  void _showPlaceInfo(String name, String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Text(address),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
      height: MediaQuery.of(context).size.height * 0.7,
      child: GoogleMap(
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          initialCameraPosition: CameraPosition(
            target: _currentPosition!,
            zoom: 11.0,
          ),
        ),
    );
  }

  PreferredSize appBarSettings(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          backgroundColor: Color(0xff145C9E),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                backButtonFunctionality();
              }),
          title: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Send location",
                  style: TextStyle(color: Colors.white)
              )),
          actions: [
            PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(value: 0, child: Text("TODO")),
                  PopupMenuItem<int>(value: 1, child: Text("TODO"))
                ])
          ]),
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        print("TODO:");
        break;
      case 1:
        print("TODO");
        break;
    }
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
        appBar: appBarSettings(context),
        body: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isLoading
                              ? Center(child: CircularProgressIndicator())
                              : mediaPreview(),
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
                            ) : Container(),
                          ),
                        ],
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
