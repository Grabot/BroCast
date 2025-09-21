import 'dart:async';
import 'dart:ui' as ui;
import 'package:brocast/objects/data_type.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import 'package:brocast/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:brocast/utils/socket_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tuple/tuple.dart';

import '../objects/bro.dart';
import '../objects/broup.dart';
import '../objects/me.dart';
import '../objects/message.dart';
import '../services/auth/v1_4/auth_service_social.dart';
import '../services/auth/v1_5/auth_service_social_v1_5.dart';
import '../../../utils/storage.dart';
import 'locator.dart';
import 'navigation_service.dart';


typedef LocationUpdateCallback = void Function(int broId, LatLng? location, bool remove);

class LocationSharing {
  static final LocationSharing _instance = LocationSharing._internal();

  final NavigationService _navigationService = locator<NavigationService>();

  Map<int, Timer?> _inactivityTimer = {};
  Map<int, Stream<Position>?> positionStream = {};
  Map<int, StreamSubscription<Position>?> _streamSubscription = {};
  final Map<int, Timer> _endTimeTimers = {};

  Map<int, LatLng> broPositions = {};
  final List<LocationUpdateCallback> _listeners = [];
  Map<int, Tuple2<BitmapDescriptor, InfoWindow>?> broMarkerIcon = {};

  // A mapping between the broupId and the endTime for the location sharing
  // We expect there only to be 1 location sharing at the time, but it's possible to share in multiple broups
  Map<int, DateTime> endTimeShareMe = {};
  Map<int, Map<int, DateTime>> endTimeShareOfTheBros = {};
  Map<int, Map<int, String>> liveSharingBroInformation = {};

  // A mapping between the broupId and the mapping of the broId for the location sharing
  // A bro can share it's location in multiple broups with variable end times
  Map<int, Map<int, Timer>> endTimeShareBroTimers = {};
  late Storage storage;

  LocationSharing._internal() {
    storage = Storage();
  }

  factory LocationSharing() {
    return _instance;
  }

  void addLocationListener(LocationUpdateCallback listener) {
    _listeners.add(listener);
  }

  Future<BitmapDescriptor> createCustomMarkerWithText(
      Uint8List avatar, String text, double avatarWidth, double avatarHeight) async {
    double textHeight = avatarHeight;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.white;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 70, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: 10000);

    double slightVerticalOffsetAndOverlap = (avatarHeight/2.5);
    final double scale = 2.0;
    final double scaledWidth = (avatarWidth * scale);
    final double scaledHeight = (avatarHeight * scale);
    final double textOffsetX = (scaledWidth - textPainter.width) / 2;
    textPainter.paint(canvas, Offset(textOffsetX, slightVerticalOffsetAndOverlap/2));

    final ui.Image avatarImage = await decodeImageFromList(avatar);
    final ui.PictureRecorder hexagonRecorder = ui.PictureRecorder();
    final Canvas hexagonCanvas = Canvas(hexagonRecorder);

    final HexagonClipper hexagonClipper = HexagonClipper();
    final Path hexagonPath = hexagonClipper.getClip(Size(scaledWidth, scaledHeight));
    hexagonCanvas.clipPath(hexagonPath);
    hexagonCanvas.drawImageRect(
      avatarImage,
      Rect.fromLTWH(0, 0, avatarImage.width.toDouble(), avatarImage.height.toDouble()),
      Rect.fromLTWH(0, 0, scaledWidth, scaledHeight),
      paint,
    );

    final ui.Image hexagonImage = await hexagonRecorder.endRecording().toImage(scaledWidth.toInt(), scaledHeight.toInt());
    canvas.drawImage(hexagonImage, Offset(0, scaledHeight-slightVerticalOffsetAndOverlap), paint);

    final Paint trianglePaint = Paint()..color = Colors.black87;
    final Path trianglePath = Path();
    double triangleSize = 20;
    trianglePath.moveTo(scaledWidth / 2, scaledHeight + (textHeight * scale) - 0);
    trianglePath.lineTo(scaledWidth / 2 - triangleSize, scaledHeight + (textHeight * scale) - 0 - triangleSize);
    trianglePath.lineTo(scaledWidth / 2 + triangleSize, scaledHeight + (textHeight * scale) - 0 - triangleSize);
    trianglePath.close();
    canvas.drawPath(trianglePath, trianglePaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(scaledWidth.toInt(), (scaledHeight + (textHeight*scale)).toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(pngBytes, width: avatarWidth, height: avatarHeight+textHeight);
  }

  String getBroEndTime(int broupId, Bro? bro) {
    DateTime? broEndTime;
    if (bro == null) {
      return "";
    }
    if (endTimeShareOfTheBros.containsKey(broupId)) {
      if (endTimeShareOfTheBros[broupId]!.containsKey(bro.getId())) {
        broEndTime = endTimeShareOfTheBros[broupId]![bro.getId()]!;
      }
    }
    String broEndTimeInformation = "Bro ${bro.getFullName()} was sharing live location";
    if (broEndTime != null) {
      broEndTimeInformation = "Bro ${bro.getFullName()} is sharing live location till ${broEndTime.hour.toString().padLeft(2, '0')}:${broEndTime.minute.toString().padLeft(2, '0')}";
    }
    return broEndTimeInformation;
  }

  setBroData(Bro bro, int broupId) async {
    DateTime? broEndTime;
    if (endTimeShareOfTheBros.containsKey(broupId)) {
      if (endTimeShareOfTheBros[broupId]!.containsKey(bro.getId())) {
        broEndTime = endTimeShareOfTheBros[broupId]![bro.getId()]!;
      }
    }
    String snippet = "Sharing live location";
    if (broEndTime != null) {
      snippet = "Sharing live location till ${broEndTime.hour.toString().padLeft(2, '0')}:${broEndTime.minute.toString().padLeft(2, '0')}";
    }
    broMarkerIcon[bro.getId()] = Tuple2(
        await createCustomMarkerWithText(
            bro.getAvatar()!,
            bro.getBromotion(),
            60,
            60
      ), InfoWindow(
        title: bro.getFullName(),
        snippet: snippet
      )
    );
  }

  Future<void> createBroMarker(int broupId, int broId) async {
    Bro? bro = await storage.fetchBro(broId);
    if (bro != null) {
      if (bro.getAvatar() != null) {
        setBroData(bro, broupId);
      } else {
        await AuthServiceSocial().getAvatarBro(broId);
        // Now the avatar should be in the database
        Bro? broAgain = await storage.fetchBro(broId);
        if (broAgain != null) {
          if (broAgain.getAvatar() != null) {
            setBroData(broAgain, broupId);
          }
        }
      }
    } else {
      Bro? newBro = await AuthServiceSocial().retrieveBroAvatar(broId);
      if (newBro != null) {
        await AuthServiceSocial().updateBroups(newBro);
        Bro? broAgain = await storage.fetchBro(broId);
        if (broAgain != null) {
          if (broAgain.getAvatar() != null) {
            setBroData(broAgain, broupId);
          }
        }
      }
    }
    return;
  }

  Future<Marker?> getBroMarker(int broupId, int broId) async {
    if (broPositions.containsKey(broId) && broPositions[broId] != null) {
      if (!broMarkerIcon.containsKey(broId)) {
        await createBroMarker(broupId, broId);
        if (broPositions.containsKey(broId)) {
          notifyListenersBro(broId, broPositions[broId]!);
        }
      }
      Tuple2<BitmapDescriptor, InfoWindow>? markerIcon = broMarkerIcon[broId];
      return Marker(
          markerId: MarkerId('bro_${broId}_Location'),
          position: broPositions[broId]!,
          icon: markerIcon?.item1 ?? BitmapDescriptor.defaultMarker,
          infoWindow: markerIcon?.item2 ?? InfoWindow(title: "Bro $broId")
      );
    } else {
      return null;
    }
  }

  getBroupLocationsInit(int broupId) async {
    List<LocationSharingData>? endTimeShares = await storage.getAllActiveLocationSharingBroup(broupId, false);
    List<int> retrieveBroLocation = [];
    if (endTimeShares != null) {
      List<int> broIdsSharing = endTimeShares.map((e) => e.broId).toList();
      for (int broId in broIdsSharing) {
        if (!broPositions.containsKey(broId)) {
          retrieveBroLocation.add(broId);
        }
        if (!broMarkerIcon.containsKey(broId)) {
          createBroMarker(broupId, broId);
        }
      }
    }
    if (retrieveBroLocation.isNotEmpty) {
      if (retrieveBroLocation.length == 1) {
        int singleBroId = retrieveBroLocation[0];
        AuthServiceSocialV15().getBroLocation(broupId, singleBroId).then((broPos) {
          if (broPos != null) {
            broPositions[singleBroId] = broPos;
            notifyListenersBro(singleBroId, broPos);
          }
        });
      } else {
        AuthServiceSocialV15().getBrosLocation(broupId, retrieveBroLocation).then((posSet) {});
      }
    }
    if (broPositions.isNotEmpty) {
      _notifyListenersBroup();
    }
  }

  void removeLocationListener(LocationUpdateCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListenersBro(int broId, LatLng location) {
    for (final listener in _listeners) {
      listener(broId, location, false);
    }
  }

  void _notifyListenersBroup() {
    for (final entry in broPositions.entries) {
      int broId = entry.key;
      LatLng location = entry.value;
      for (final listener in _listeners) {
        listener(broId, location, false);
      }
    }
  }

  startSharingAll(Me me) async {
    List<LocationSharingData>? endTimeShares = await storage.getAllActiveLocationSharing();
    if (endTimeShares != null) {
      List<LocationSharingData> timeShareMe = endTimeShares.where((share) => share.meSharing).toList();
      List<LocationSharingData> timeShareBros = endTimeShares.where((share) => !share.meSharing).toList();
      for (LocationSharingData endTimeShare in timeShareMe) {
        int broupId = endTimeShare.broupId;
        DateTime endTime = endTimeShare.dateTime.toLocal();
        if (DateTime.now().toLocal().isAfter(endTime)) {
          // Now is after the endtime so the sharing is over.
          if (endTimeShareMe.containsKey(broupId)) {
            endTimeShareMe.remove(broupId);
          }
          storage.removeLocationSharing(me.id, broupId, true);
        } else {
          int messageId = endTimeShare.messageId;
          if (messageId != -1) {
            startSharing(me, broupId, endTime, messageId);
          }
        }
      }
      // Check if other bros are sharing
      for (LocationSharingData endTimeShareBro in timeShareBros) {
        int broId = endTimeShareBro.broId;
        int broupId = endTimeShareBro.broupId;
        DateTime endTime = endTimeShareBro.dateTime.toLocal();
        if (DateTime.now().toLocal().isAfter(endTime)) {
          // no longer sharing, so remove the bro entry from the list
          await broShareTimeReached(broupId, broId, false);
        } else {
          getLocationSharingInformation(broupId, broId, endTime);
          if (!endTimeShareBroTimers.containsKey(broupId)) {
            endTimeShareBroTimers[broupId] = {};
          }
          if (endTimeShareBroTimers[broupId]![broId] != null) {
            endTimeShareBroTimers[broupId]![broId]!.cancel();
          }
          endTimeShareBroTimers[broupId]![broId] = Timer(Duration(milliseconds: endTime.toLocal().difference(DateTime.now().toLocal()).inMilliseconds), () async {
            await broShareTimeReached(endTimeShareBro.broupId, endTimeShareBro.broId, false);
          });
        }
      }
    }
  }

  broShareTimeReached(int broupId, int broId, bool meSharing) async {
    await storage.removeLocationSharing(broId, broupId, meSharing);
    if (endTimeShareBroTimers.containsKey(broupId)) {
      endTimeShareBroTimers[broupId]!.remove(broId);
    }
    if (broPositions.containsKey(broId)) {
      broPositions.remove(broId);
    }
    if (broMarkerIcon.containsKey(broId)) {
      broMarkerIcon.remove(broId);
    }
    if (liveSharingBroInformation.containsKey(broupId)) {
      if (liveSharingBroInformation[broupId]!.containsKey(broId)) {
        liveSharingBroInformation[broupId]!.remove(broId);
        if (liveSharingBroInformation[broupId]!.isEmpty) {
          liveSharingBroInformation.remove(broupId);
        }
      }
    }
    if (endTimeShareOfTheBros.containsKey(broupId)) {
      if (endTimeShareOfTheBros[broupId]!.containsKey(broId)) {
        endTimeShareOfTheBros[broupId]!.remove(broId);
        if (endTimeShareOfTheBros[broupId]!.isEmpty) {
          endTimeShareOfTheBros.remove(broupId);
        }
      }
    }
    for (final listener in _listeners) {
      listener(broId, null, true);
    }
  }

  startEndTimeBroTimer(DateTime endTime, int broupId, int broId) async {
    getLocationSharingInformation(broupId, broId, endTime);
    if (!endTimeShareBroTimers.containsKey(broupId)) {
      endTimeShareBroTimers[broupId] = {};
    }
    if (endTimeShareBroTimers[broupId]![broId] != null) {
      endTimeShareBroTimers[broupId]![broId]!.cancel();
    }
    if (!broPositions.containsKey(broId)) {
      LatLng? broPos = await AuthServiceSocialV15().getBroLocation(broupId, broId);
      if (broPos != null) {
        broPositions[broId] = broPos;
        notifyListenersBro(broId, broPos);
      }
    }
    endTimeShareBroTimers[broupId]![broId] = Timer(Duration(milliseconds: endTime.toLocal().difference(DateTime.now().toLocal()).inMilliseconds), () async {
      await broShareTimeReached(broupId, broId, false);
    });
  }

  void startSharing(Me me, int broupId, DateTime endTime, int messageId) async {
    await stopSharingLocation(me,  broupId);
    await storage.addLocationSharing(
        broId: me.id,
        broupId: broupId,
        endTime: endTime,
        meSharing: true,
        messageId: messageId
    );
    getLocationSharingInformation(broupId, me.id, endTime);
    endTimeShareMe[broupId] = endTime;

    _endTimeTimers[broupId]?.cancel();

    positionStream[broupId] = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update if user moves 10 meters
      ),
    );

    void _startInactivityTimer(int broupId) {
      _inactivityTimer[broupId]?.cancel();
      _inactivityTimer[broupId] = Timer(const Duration(minutes: 5), () {

        Geolocator.getLastKnownPosition().then((Position? position) {
          if (position != null) {
            SocketServices().updateLocation(
              me.getId(),
              broupId,
              position.latitude,
              position.longitude,
            );
          }
        }).catchError((e) {
          showToastMessage("Error getting last known position: $e");
        });
        _startInactivityTimer(broupId); // Restart the timer after forced update
      });
    }

    _streamSubscription[broupId] = positionStream[broupId]!.listen((Position position) {
      SocketServices().updateLocation(
        me.getId(),
        broupId,
        position.latitude,
        position.longitude,
      );

      // Reset the inactivity timer
      _inactivityTimer[broupId]?.cancel();
      _startInactivityTimer(broupId);
    });

    // Start the initial timer
    _startInactivityTimer(broupId);
    _endTimeTimers[broupId] = Timer(Duration(milliseconds: endTime.toLocal().difference(DateTime.now().toLocal()).inMilliseconds), () {
      stopSharingLocation(me, broupId);
    });
  }

  Future stopSharingLocation(Me me, int broupId) async {
    if (_streamSubscription.containsKey(broupId)) {
      await _streamSubscription[broupId]?.cancel();
      _streamSubscription.remove(broupId);
    }
    if (positionStream.containsKey(broupId)) {
      positionStream.remove(broupId);
    }
    if (_inactivityTimer.containsKey(broupId)) {
      _inactivityTimer[broupId]?.cancel();
      _inactivityTimer.remove(broupId);
    }
    if (endTimeShareMe.containsKey(broupId)) {
      endTimeShareMe.remove(broupId);
    }
    if (_endTimeTimers.containsKey(broupId)) {
      _endTimeTimers[broupId]?.cancel();
      _endTimeTimers.remove(broupId);
    }
    await broShareTimeReached(broupId, me.id, true);
    return;
  }

  updateBroLocation(int broId, LatLng location) {
    broPositions[broId] = location;
    notifyListenersBro(broId, location);
  }

  Future<void> getLocation() async {
    // 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showToastMessage("Location services are disabled. Please enable them in settings.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToastMessage("Location permissions are denied. Cannot fetch location.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showToastMessage("Location permissions are permanently denied. Please enable them in app settings.");
      return;
    }
  }

  getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToastMessage("Location permissions are denied. Cannot fetch location.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showToastMessage("Location permissions are permanently denied. Please enable them in app settings.");
      return;
    }
  }

  getLocationSharingInformation(int broupId, int broId, DateTime broEndTime) {
    if (!endTimeShareOfTheBros.containsKey(broupId)) {
      endTimeShareOfTheBros[broupId] = {};
    }
    endTimeShareOfTheBros[broupId]![broId] = broEndTime;
    storage.fetchBro(broId).then((bro) {
      if (!liveSharingBroInformation.containsKey(broupId)) {
        liveSharingBroInformation[broupId] = {};
      }
      liveSharingBroInformation[broupId]![broId] = "";
      if (bro != null) {
        liveSharingBroInformation[broupId]![broId] = "Bro ${bro.getFullName()} is sharing live location till ${broEndTime.hour.toString().padLeft(2, '0')}:${broEndTime.minute.toString().padLeft(2, '0')}";
      } else {
        liveSharingBroInformation[broupId]![broId] = "live location shared";
      }
    });
  }

  sendMessageStopSharing(Me? me, int broupId, Message liveLocationMessage) async {
    // loop over the broups on `me` to find the one with the broupId
    Broup? currentBroup = null;
    if (me == null) {
      showToastMessage("we had an issues getting your user information. Please log in again.");
      _navigationService.navigateTo(routes.SignInRoute);
      return;
    }
    for (Broup broup in me.broups) {
      if (broup.broupId == broupId) {
        currentBroup = broup;
        break;
      }
    }
    if (currentBroup == null) {
      Broup? dbBroup = await storage.fetchBroup(broupId);
      if (dbBroup != null) {
        currentBroup = dbBroup;
      }
    }
    if (currentBroup == null) {
      showToastMessage("we had an issues getting your user information. Please log in again.");
      _navigationService.navigateTo(routes.SignInRoute);
      return;
    }
    int meId = -1;
    int newMessageId = currentBroup.lastMessageId + 1;
    meId = me.getId();

    String message = "🚫🗺️📍😭";
    String textMessage = "Stopped sharing live location";
    Message mes = Message(
      messageId: newMessageId,
      senderId: meId,
      body: message,
      textMessage: textMessage,
      timestamp: DateTime.now().toUtc().toString(),
      data: null,
      dataType: DataType.liveLocationStop.value,
      info: false,
      broupId: currentBroup.broupId,
      repliedMessage: liveLocationMessage,
      repliedTo: liveLocationMessage.messageId,
    );
    mes.isRead = 2;
    if (currentBroup.messages.length > 0) {
      currentBroup.messages.insert(0, mes);
    }

    currentBroup.sendingMessage = true;

    await storage.addMessage(mes);
    // Send the message. The data is always null here because it's only send via the preview page.
    int? messageId = await AuthServiceSocialV15().sendMessageLocation(currentBroup.getBroupId(), message, textMessage, null, DataType.liveLocationStop.value, liveLocationMessage.messageId);
    // isLoadingMessages = false;
    // We predict what the messageId will be but in the end it is determined by the server.
    // If it's different we want to update it.
    if (messageId != null) {
      mes.isRead = 0;
      if (mes.messageId != messageId) {
        await storage.updateMessageId(mes.messageId, messageId, currentBroup.broupId);
        mes.messageId = messageId;
      }
      // message send
    } else {
      // The message was not sent, we remove it from the list and the database
      storage.deleteMessage(mes.messageId, currentBroup.broupId);
      showToastMessage("there was an issue sending the message");
      for (int i = 0; i < 5; i++) {
        // There might be some messages retrieved in between this period.
        // While this is unlikely, check for the correct message to remove.
        if (currentBroup.messages[i] == mes) {
          currentBroup.messages.removeAt(i);
          break;
        }
      }
    }
    currentBroup.sendingMessage = false;
    return;
  }
}

class LocationSharingData {
  late DateTime dateTime;
  late int broupId;
  late int broId;
  late bool meSharing;
  late int messageId;

  LocationSharingData(this.dateTime, this.broupId, this.broId, this.meSharing, this.messageId);

  LocationSharingData.fromDbMap(Map<String, dynamic> map) {
    broupId = map['broupId'];
    String endTimeString = map['endTime'];
    dateTime = DateTime.parse(endTimeString).toLocal();
    broId = map["broId"];
    meSharing = map["meSharing"] == 1;
    messageId = map["messageId"];
  }
}
