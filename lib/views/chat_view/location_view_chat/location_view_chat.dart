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
import 'package:collection/collection.dart';
import '../../../constants/base_url.dart';
import '../../../objects/broup.dart';
import '../../../objects/me.dart';
import '../../../objects/message.dart';
import '../../../services/auth/v1_5/auth_service_social_v1_5.dart';
import '../../../utils/location_sharing.dart';
import '../../../utils/locator.dart';
import '../../../utils/navigation_service.dart';
import '../../../utils/secure_storage.dart';
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
  String? _previousSelectedMarkerId;
  String? _selectedMarkerInfo;
  bool showMarkerInfo = false;
  late BitmapDescriptor greenDotIcon;
  late BitmapDescriptor redDotIcon;

  double mapsCameraPositionLatitude = 0;
  double mapsCameraPositionLongitude = 0;
  bool _showCurrentLocationMarker = false;
  double currentMarkerIconSize = 40;
  bool markerTapped = false;
  bool showCurrentLocationMarkerInfo = false;

  LatLng? selectedLocation;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getLocation();
    broMessageController.text = "🗺️📍";
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

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          isLoading = false;
          showToastMessage("Location services are disabled. Please enable them in settings.");
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            isLoading = false;
            showToastMessage("Location permissions are denied. Cannot fetch location.");
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLoading = false;
          showToastMessage("Location permissions are permanently denied. Please enable them in app settings.");
        });
        return;
      }

      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update if user moves 10 meters
        ),
      ).listen((Position position) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          if (mapsCameraPositionLatitude != 0 && mapsCameraPositionLongitude != 0) {
            checkDistance(mapsCameraPositionLatitude, mapsCameraPositionLongitude);
          }
        });
      });

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        mapsCameraPositionLatitude = position.latitude;
        mapsCameraPositionLongitude = position.longitude;
        isLoading = false;
      });

      await _fetchNearbyPlaces(_currentPosition!);
    } on TimeoutException {
      setState(() {
        isLoading = false;
        showToastMessage("Timeout while fetching location. Please try again.");
      });
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
        showToastMessage("Failed to get location: ${e.message}");
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        showToastMessage("An unexpected error occurred: $e");
      });
    }
  }


  Future<void> _fetchNearbyPlaces(LatLng location) async {
    try {
      final response = await _dio.post(
        'https://places.googleapis.com/v1/places:searchNearby',
        data: jsonEncode({
          "includedTypes": [
            "restaurant",
            "tourist_attraction",
            "museum",
            "park",
            "cafe",
            "shopping_mall",
            "amusement_park",
            "zoo",
            "aquarium",
            "stadium"
          ],
          "maxResultCount": 10,
          "rankPreference": "POPULARITY",
          "locationRestriction": {
            "circle": {
              "center": {
                "latitude": location.latitude,
                "longitude": location.longitude,
              },
              "radius": 500.0,
            }
          },
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': MAPS_API_KEY_WEB,
            'X-Goog-FieldMask': 'places.displayName,places.location,places.id,places.formattedAddress',
          },
        ),
      );

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
              infoWindow: InfoWindow.noText,
              onTap: () {
                setState(() {
                  markerTapped = true;
                  _selectedMarkerId = markerId;
                  _selectedMarkerInfo = "${name["text"]}\n${place['formattedAddress'] ?? 'No address available'}";
                  _updateMarkers();
                });
              },
            ),
          );
        }
        setState(() {});
      } else {
        if (mounted) {
          showToastMessage("Failed to fetch places");
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        showToastMessage("Error fetching places: ${e.message}");
      }
    }
  }

  void _updateMarkers() {
    setState(() {
      Marker? updatedMarker = _markers.firstWhereOrNull(
            (marker) => marker.markerId.value == _selectedMarkerId,
      );

      if (updatedMarker != null) {
        _markers.remove(updatedMarker);
        _markers.add(updatedMarker.copyWith(iconParam: redDotIcon));
      }

      if (_previousSelectedMarkerId != null) {
        Marker? updatedMarkerBack = _markers.firstWhereOrNull(
              (marker) => marker.markerId.value == _previousSelectedMarkerId,
        );
        if (updatedMarkerBack != null) {
          _markers.remove(updatedMarkerBack);
          _markers.add(updatedMarkerBack.copyWith(iconParam: greenDotIcon));
        }
      }
      _previousSelectedMarkerId = _selectedMarkerId;
    });
  }

  double getRemainingHeight() {
    double appBarHeight = 50.0;
    double locationButtons = 102; // The location buttons + divider
    double emojiKeyboardHeight = showEmojiKeyboard
        ? 350.0 + locationButtons
        : locationButtons;
    double regularKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double bottomPadding = showEmojiKeyboard ? 0 : MediaQuery.of(context).padding.bottom;
    double textFieldHeight = 90;
    if (appendingCaption) {
      textFieldHeight += 46;
    }
    double paddingHeight = 20;

    double remainingHeight = MediaQuery.of(context).size.height -
        appBarHeight -
        emojiKeyboardHeight -
        bottomPadding -
        regularKeyboardHeight -
        textFieldHeight -
        paddingHeight;
    // 200 is the minimum we need
    if (remainingHeight < 200) {
      remainingHeight = 200;
    }
    return remainingHeight;
  }

  double _calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  Widget showCurrentLocationMarkerLabel() {
    if (_showCurrentLocationMarker && showCurrentLocationMarkerInfo && _selectedMarkerId == null) {
      String labelText = "Selected location";
      TextStyle style = TextStyle(color: Colors.black, fontSize: 16);
      double labelWidth = _calculateTextWidth(labelText, style);
      double remainingWidth = MediaQuery.of(context).size.width - labelWidth;
      return Positioned(
        top: getRemainingHeight() / 2 - 80,
        left: remainingWidth / 2,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            labelText,
            style: style,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget showSelectedMarkerLabel() {
    if (showMarkerInfo && _selectedMarkerInfo != null) {
      TextStyle style = TextStyle(color: Colors.black, fontSize: 16);
      double labelWidth = _calculateTextWidth(_selectedMarkerInfo!, style);
      double remainingWidth = MediaQuery
          .of(context)
          .size
          .width - labelWidth;
      return Positioned(
        top: getRemainingHeight() / 2 - 100,
        left: remainingWidth / 2,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _selectedMarkerInfo!,
            style: style,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  checkDistance(double latitude, double longitude) {
    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );

    if (distance > 50) {
      if (!_showCurrentLocationMarker) {
        setState(() {
          _showCurrentLocationMarker = true;
        });
      }
    } else {
      if (_showCurrentLocationMarker) {
        setState(() {
          _showCurrentLocationMarker = false;
        });
      }
    }
  }

  Widget mediaPreview() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: getRemainingHeight(),
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: calculateZoomLevel(500),
            ),
            markers: _markers,
            mapType: MapType.normal,
            onCameraMove: (CameraPosition position) {
              mapsCameraPositionLatitude = position.target.latitude;
              mapsCameraPositionLongitude = position.target.longitude;
              if (!markerTapped) {
                setState(() {
                  showMarkerInfo = false;
                  showCurrentLocationMarkerInfo = false;
                  _selectedMarkerId = null;
                  _updateMarkers();
                });
              }
              selectedLocation = position.target;
              // Show marker if the map is moved away from current location
              if (_currentPosition != null) {
                checkDistance(position.target.latitude, position.target.longitude);
              }
            },
            onCameraIdle: () {
              if (markerTapped) {
                setState(() {
                  showMarkerInfo = true;
                  markerTapped = false;
                });
              } else {
                setState(() {
                  showCurrentLocationMarkerInfo = true;
                });
              }
            },
            onTap: (LatLng pos) {
              setState(() {
                _selectedMarkerId = null;
                _updateMarkers();
              });
            },
          ),
          if (_showCurrentLocationMarker)
            Positioned(
              top: getRemainingHeight() / 2 - (currentMarkerIconSize+2),
              left: MediaQuery.of(context).size.width / 2 - (currentMarkerIconSize/2),
              child: Icon(
                Icons.location_on,
                color: widget.chat.getColor(),
                size: currentMarkerIconSize,
              ),
            ),
          showSelectedMarkerLabel(),
          showCurrentLocationMarkerLabel()
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
        broMessageController.text = "🗺️📍";
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

  String latLngToString(LatLng location) {
    return '${location.latitude},${location.longitude}';
  }

  sendLocationMessage(String messageLoc, bool liveLocation, DateTime? endTime) async {
    String message = broMessageController.text;
    String? textMessage;
    if (captionMessageController.text != "") {
      textMessage = captionMessageController.text;
    }
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
    int dataType = DataType.location.value;
    if (liveLocation) {
      dataType = DataType.liveLocation.value;
    }
    if (formKey.currentState!.validate()) {
      Message mes = Message(
          messageId: newMessageId,
          senderId: meId,
          body: message,
          textMessage: textMessage,
          timestamp: DateTime.now().toUtc().toString(),
          data: messageLoc,
          dataType: dataType,
          info: false,
          broupId: widget.chat.getBroupId()
      );
      mes.isRead = 2;
      mes.dataIsReceived = true;
      setState(() {
        widget.chat.messages.insert(0, mes);
      });
      setState(() {
        widget.chat.sendingMessage = true;
      });

      AuthServiceSocialV15().sendMessageLocation(widget.chat.getBroupId(), message, textMessage, messageLoc, dataType, null).then((messageId) async {
        setState(() {
          isSending = false;
        });
        if (messageId != null) {
          mes.isRead = 0;
          if (mes.messageId != messageId) {
            mes.messageId = messageId;
          }
          await Storage().addMessage(mes);
          // Message send correctly start live location if data type is live type
          if (dataType == DataType.liveLocation.value && endTime != null) {
            Me? me = settings.getMe();
            if (me == null) {
              return;
            }
            LocationSharing().startSharing(me, widget.chat.getBroupId(), endTime.toLocal(), mes.messageId);
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

  sendSelectedLocation() {
    if (selectedLocation != null) {
      sendLocationMessage(latLngToString(selectedLocation!), false, null);
    } else {
      showToastMessage("Something went wrong");
    }
  }

  sendCurrentLocation() {
    if (_currentPosition != null) {
      sendLocationMessage(latLngToString(_currentPosition!), false, null);
    } else {
      showToastMessage("Something went wrong");
    }
  }

  Widget currentOrSelectedButton() {
    if (_showCurrentLocationMarker) {
      return GestureDetector(
        onTap: () {
          if (!isLoading) {
            sendSelectedLocation();
          }
        },
        child: Container(
          padding: EdgeInsets.all(6),
          height: 50,
          color: widget.chat.getColor(),
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
              Text("Send selected location", style: TextStyle(color: getTextColor(Colors.white), fontSize: 16)),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (!isLoading) {
            sendCurrentLocation();
          }
        },
        child: Container(
          padding: EdgeInsets.all(6),
          height: 50,
          color: widget.chat.getColor(),
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
              Text("Send current location", style: TextStyle(color: getTextColor(Colors.white), fontSize: 16)),
            ],
          ),
        ),
      );
    }
  }

  Widget getLocationButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!isLoading) {
              showDialogLiveLocationChat(context);
            }
          },
          child: Container(
            padding: EdgeInsets.all(6),
            height: 50,
            color: widget.chat.getColor(),
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
                Text("Share live location", style: TextStyle(color: getTextColor(Colors.white), fontSize: 16)),
              ],
            ),
          ),
        ),
        Divider(color: Colors.grey[800], height: 2),
        currentOrSelectedButton(),
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
                    PopupMenuItem<int>(value: 0, child: Text("Back to Chat")),
                  ])
            ]
            ),
      ),
    );
  }

  void onSelectLocation(BuildContext context, int item) {
    switch (item) {
      case 0:
        exitPreviewMode();
        break;
    }
  }

  startShareLocation(int selectedIndex) {
    DateTime now = DateTime.now().toUtc();
    DateTime endTime;
    if (selectedIndex == 0) {
      endTime = now.add(Duration(minutes: 15));
    } else if (selectedIndex == 1) {
      endTime = now.add(Duration(hours: 1));
    } else {
      // selectedIndex = 2
      endTime = now.add(Duration(hours: 8));
    }
    Navigator.of(context).pop();
    String location = latLngToString(_currentPosition!);
    String endTimeString = endTime.toIso8601String();
    String locationWithEndTime = '$location;$endTimeString';
    sendLocationMessage(locationWithEndTime, true, endTime);
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

  void showDialogLiveLocationChat(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = 0;
          return AlertDialog(
            title: new Text("Share live location for..."),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(3, (int index) {
                    return InkWell(
                      onTap: () {
                        setState(() => selectedRadio = index);
                      },
                      child: Row(children: [
                        Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (int? value) {
                              if (value != null) {
                                setState(() => selectedRadio = value);
                              }
                            }),
                        index == 0
                            ? Container(child: Text("15 minutes"))
                            : Container(),
                        index == 1
                            ? Container(child: Text("1 hour"))
                            : Container(),
                        index == 2
                            ? Container(child: Text("8 hours"))
                            : Container(),
                      ]),
                    );
                  }),
                );
              },
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Share"),
                onPressed: () {
                  startShareLocation(selectedRadio);
                },
              ),
            ],
          );
        });
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
