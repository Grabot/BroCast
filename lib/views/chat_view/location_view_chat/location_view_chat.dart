import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:brocast/objects/data_type.dart';
import 'package:dio/dio.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Broup chat;

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
  Set<Marker> _markers = {};
  final Dio _dio = Dio();

  String? _selectedMarkerId;
  late BitmapDescriptor greenDotIcon;
  late BitmapDescriptor redDotIcon;

  bool _showCurrentLocationMarker = false;
  CameraPosition? _currentCameraPosition;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getLocation();
    broMessageController.text = "🗺️";
    _loadCustomIcons();
  }

  Future<void> _loadCustomIcons() async {
    ByteData greenDotData = await rootBundle.load('assets/images/green_dot.png');
    ByteData redDotData = await rootBundle.load('assets/images/red_dot.png');
    Uint8List greenDotBytes = greenDotData.buffer.asUint8List();
    Uint8List redDotBytes = redDotData.buffer.asUint8List();
    greenDotIcon = BitmapDescriptor.bytes(
        greenDotBytes
    );
    redDotIcon = BitmapDescriptor.bytes(
        redDotBytes,
    );
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
      _fetchNearbyPlaces(_currentPosition!);
      isLoading = false;
    });
  }

  Future<void> _fetchNearbyPlaces(LatLng location) async {
    try {
      final response = await _dio.post(
        'https://places.googleapis.com/v1/places:searchNearby',
        data: jsonEncode({
          "includedTypes": ["restaurant"],
          "maxResultCount": 10,
          "rankPreference": "POPULARITY",
          "locationRestriction": {
            "circle": {
              "center": {
                "latitude": location.latitude,
                "longitude": location.longitude,
              },
              "radius": 100.0,
            }
          },
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': MAPS_API_KEY,
            'X-Goog-FieldMask': 'places.displayName,places.location,places.id,places.formattedAddress',
          },
        ),
      );

      print("Response: ${response.data}");
      if (response.statusCode == 200) {
        final results = response.data['places'] as List;

        _markers.clear();
        for (var place in results) {
          final lat = place['location']['latitude'];
          final lng = place["location"]["longitude"];
          final name = place['displayName'];
          final markerId = place['id'];

          _markers.add(
            Marker(
              markerId: MarkerId(markerId),
              position: LatLng(lat, lng),
              icon: greenDotIcon,
              infoWindow: InfoWindow(
                  title: name["text"],
                  snippet: place['formattedAddress'] ?? 'No address available'
              ),
              onTap: () {
                setState(() {
                  _selectedMarkerId = markerId;
                  _updateMarkers();
                });
              },
            ),
          );
        }
        _updateCurrentLocationMarker();
        setState(() {});
      } else {
        showToastMessage("Failed to fetch places");
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      showToastMessage("Error fetching places: ${e.message}");
    }
  }

  void _updateMarkers() {
    setState(() {
      _markers = _markers.map((marker) {
        if (marker.markerId.value == "current_location") {
          return marker; // Keep the default marker as is
        }
        return marker.copyWith(
          iconParam: marker.markerId.value == _selectedMarkerId
              ? redDotIcon
              : greenDotIcon,
        );
      }).toSet();
    });
  }

  double getRemainingHeight() {
    double appBarHeight = 50.0;
    double locationButtons = 102; // The location buttons + divider
    if (_selectedMarkerId != null) {
      locationButtons += 50; // The added 'select' button
    }
    double emojiKeyboardHeight = showEmojiKeyboard
        ? 350.0 + locationButtons
        : locationButtons;
    double bottomPadding = showEmojiKeyboard ? 0 : MediaQuery.of(context).padding.bottom;
    double textFieldHeight = 90;
    if (appendingCaption) {
      textFieldHeight += 45;
    }

    double remainingHeight = MediaQuery.of(context).size.height -
        appBarHeight -
        emojiKeyboardHeight -
        bottomPadding -
        textFieldHeight;
    return remainingHeight;
  }

  Widget mediaPreview() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: getRemainingHeight(),
      child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 17.0,
              ),
              markers: _markers,
              mapType: MapType.normal,
              onCameraMove: (CameraPosition position) {
                _currentCameraPosition = position;
                // Show marker if the map is moved away from current location
                if (_currentPosition != null) {
                  final distance = Geolocator.distanceBetween(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                    position.target.latitude,
                    position.target.longitude,
                  );
                  print("distance: $distance");
                  if (distance > 50) {
                    setState(() {
                      _showCurrentLocationMarker = true;
                      _updateCurrentLocationMarker();
                    });
                  }
                }
              },
              onTap: (LatLng pos) {
                setState(() {
                  _selectedMarkerId = null;
                  _updateMarkers();
                });
              },
            ),
          ]
      ),
    );
  }

  void _updateCurrentLocationMarker() {
    if (_showCurrentLocationMarker && _currentPosition != null) {
      _markers.removeWhere((marker) => marker.markerId.value == "current_location");
      _markers.add(
        Marker(
          markerId: MarkerId("current_location"),
          position: _currentCameraPosition!.target,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: "Your Location"),
        ),
      );
      _updateMarkers();
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
    navigateToChat(context, settings, widget.chat);
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
    int meId = -1;
    int newMessageId = widget.chat.lastMessageId + 1;
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
          broupId: widget.chat.getBroupId()
    );
      mes.isRead = 2;
      setState(() {
        widget.chat!.messages.insert(0, mes);
      });
      setState(() {
        widget.chat.sendingMessage = true;
      });
      await Storage().addMessage(mes);

      AuthServiceSocialV15().sendMessage(widget.chat.getBroupId(), message, messageTextMessage, messageData, DataType.audio.value, null).then((messageId) {
        setState(() {
          isSending = false;
        });
        if (messageId != null) {
          mes.isRead = 0;
          if (mes.messageId != messageId) {
            Storage().updateMessageId(mes.messageId, messageId, widget.chat.getBroupId());
            mes.messageId = messageId;
          }
          setState(() {
            navigateToChat(context, settings, widget.chat);
          });
        } else {
          Storage().deleteMessage(mes.messageId, widget.chat.broupId);
          showToastMessage("there was an issue sending the message");
          widget.chat.messages.removeAt(0);
        }
        setState(() {
          widget.chat.sendingMessage = false;
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

  Widget selectedLocationButton() {
    if (_selectedMarkerId == null) {
      return Container();
    } else {
      return Container(
        height: 50,
        color: widget.chat.getColor(),
        child: GestureDetector(
          onTap: () {
            print("send selected location");
          },
          child: Container(
            padding: EdgeInsets.all(6),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.gps_fixed,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text("Send selected location", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }
  }
  Widget getLocationButtons() {
    return Column(
      children: [
        Container(
          height: 50,
          color: darken(widget.chat.getColor(), 0.5),
          child: GestureDetector(
            onTap: () {
              print("Share live location");
            },
            child: Container(
              padding: EdgeInsets.all(6),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center, // Center all children
                      children: [
                        // White circular border (smaller than the green circle)
                        CustomPaint(
                          painter: PartialCircleBorderPainter(
                            color: Colors.white,
                            strokeWidth: 2.0,
                            radius: 10, // Half the height of the vertical lines
                          ),
                          size: Size(24, 24), // Match the icon size
                        ),
                        // Icon (centered)
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20, // Icon size
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Text("Share live location", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
        Divider(color: Colors.grey[800], height: 2),
        Container(
          height: 50,
          color: darken(widget.chat.getColor(), 0.5),
          child: GestureDetector(
            onTap: () {
              print("send current location");
            },
            child: Container(
              padding: EdgeInsets.all(6),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.gps_fixed,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text("Send current location", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
        selectedLocationButton(),
        showEmojiKeyboard ? Container() : SizedBox(
          height: MediaQuery.of(context).padding.bottom,
        )
      ],
    );
  }

  Widget mapsPlaceholder() {
    double remainingHeight = getRemainingHeight();
    return Container(
      height: remainingHeight,
      child: Center(child: CircularProgressIndicator())
    );
  }

  Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    return Color.lerp(color, Colors.black, amount)!;
  }

  PreferredSize appBarLocation() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Container(
        color: widget.chat.getColor(),
        child: AppBar(
            leading: IconButton(
                icon:
                Icon(Icons.arrow_back, color: getTextColor(widget.chat.getColor())),
                onPressed: () {
                  backButtonFunctionality();
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
                      child: Text(widget.chat.getBroupNameOrAlias(),
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
                  onSelected: (item) => onSelectLocation(context, item),
                  itemBuilder: (context) => [
                    PopupMenuItem<int>(value: 0, child: Text("Profile")),  // TODO:
                    PopupMenuItem<int>(value: 1, child: Text("Settings")),
                    PopupMenuItem<int>(
                        value: 2, child: Text("Broup details")),
                    PopupMenuItem<int>(value: 3, child: Text("Home"))
                  ])
            ]
            ),
      ),
    );
  }

  void onSelectLocation(BuildContext context, int item) {
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
        appBar: appBarLocation(),
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
                              ? mapsPlaceholder()
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
                                                if (widget.chat.isRemoved()) {
                                                  return "Can't send messages to a blocked bro";
                                                }
                                                return null;
                                              },
                                              onTap: () {
                                                onTapEmojiTextField();
                                              },
                                              keyboardType: TextInputType.multiline,
                                              maxLines: 1,
                                              controller: broMessageController,
                                              style: simpleTextStyle(),
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
                                        height: 45,
                                        padding: EdgeInsets.only(left: 15),
                                        child: Form(
                                          child: TextFormField(
                                            onTap: () {
                                              onTapCaptionTextField();
                                            },
                                            focusNode: focusCaptionField,
                                            keyboardType: TextInputType.multiline,
                                            maxLines: 1,
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
                  getLocationButtons(),
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

class PartialCircleBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  PartialCircleBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width/2, size.height / 2),
        radius: radius,
      ),
      1.75 * pi,
      pi/2,
      false,
      paint,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width/2, size.height / 2),
        radius: radius,
      ),
      0.75 * pi,
      pi/2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
