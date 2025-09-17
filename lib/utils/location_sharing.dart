import 'dart:async';
import 'dart:ui' as ui;
import 'package:brocast/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:brocast/utils/socket_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tuple/tuple.dart';

import '../objects/bro.dart';
import '../objects/me.dart';
import '../objects/message.dart';
import '../services/auth/v1_5/auth_service_social_v1_5.dart';
import '../../../utils/storage.dart';


typedef LocationUpdateCallback = void Function(int broId, LatLng? location, bool remove);

class LocationSharing {
  static final LocationSharing _instance = LocationSharing._internal();

  // TODO: Check if the nullable can be removed.
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

  // A mapping between the broupId and the mapping of the broId for the location sharing
  // A bro can share it's location in multiple broups with variable end times
  Map<int, Map<int, Timer>> endTimeShareBroTimers = {};

  LocationSharing._internal() {
  }

  factory LocationSharing() {
    return _instance;
  }

  void addLocationListener(LocationUpdateCallback listener) {
    print("Adding Location listener");
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

  Future<void> createBroMarker(int broId) async {
    Bro? bro = await Storage().fetchBro(broId);
    if (bro != null) {
      if (bro.getAvatar() != null) {
        print("Creating marker for bro ${bro.getId()}");
        broMarkerIcon[bro.getId()] = Tuple2(await createCustomMarkerWithText(
            bro.getAvatar()!,
            bro.getBromotion(),
            60,
            60
        ), InfoWindow(
            title: bro.getFullName(),
            snippet: "Sharing live location till 6.23"
        ));
      } else {
        print("no avatar?");
        // TODO: retrieve avatar?
      }
    } else {
      print("bro not found?");
      // TODO: retrieve bro?
    }
    return;
  }

  Future<Marker?> getBroMarker(int broId) async {
    if (broPositions.containsKey(broId) && broPositions[broId] != null) {
      if (!broMarkerIcon.containsKey(broId)) {
        print("creating bro marker icon");
        await createBroMarker(broId);
        if (broPositions.containsKey(broId)) {
          _notifyListenersBro(broId, broPositions[broId]!);
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
    // TODO: Check how many bros are sharing live locations and how many of those are available in `broPositoins` (If all of them are in the set we don't need to get the broup location)
    // TODO: If there is only 1 we need we can call getBroLocation instead of getBroupLocation
    // This will update the initial locations of the bros with live location on.

    // TODO: We can check who is live sharing via the securestorage thing for bros. (Changed to Storage)
    // We will fetch the broup in storage to loop over the bros to already create the markers.
    Storage().fetchBroup(broupId).then((broup) {
      if (broup != null) {
        for (int broId in broup.broIds) {
          if (!broMarkerIcon.containsKey(broId)) {
            createBroMarker(broId);
          }
        }
      }
    });
    AuthServiceSocialV15().getBroupLocation(broupId).then((val) {
      if (val) {
        _notifyListenersBroup();
      }
    });
  }

  Future<Marker?> initializeMessageTileMarker(Message message, bool myMessage) async {
    // String locationPart = message.data!.split(';')[0];
    // String timePart = message.data!.split(';')[1];
    // DateTime endTime = DateTime.parse(timePart).toLocal();
    Marker? initializedMarker;
    LatLng? broLocation = broPositions[message.senderId];
    if (broLocation != null) {
      print("it picked up a location");
      initializedMarker = Marker(
        markerId: MarkerId('bro_${message.senderId}_Location'),
        position: broLocation,
      );
    } else {
      // TODO: In this situation just get the location from the server.
      print("it came here!!!!");
      AuthServiceSocialV15().getBroLocation(message.broupId, message.senderId).then((value) {
        print("got location :)");
        if (value != null) {
          print("updated location!!@2");
          broPositions[message.senderId] = value;
          _notifyListenersBro(message.senderId, value);
        } else {
          // TODO: What to do?
        }
      });
    }
    return initializedMarker;
  }

  void removeLocationListener(LocationUpdateCallback listener) {
    print("Removing Location listener");
    _listeners.remove(listener);
  }

  void _notifyListenersBro(int broId, LatLng location) {
    print("Notifying listeners $_listeners");
    for (final listener in _listeners) {
      listener(broId, location, false);
    }
  }

  void _notifyListenersBroup() {
    for (final entry in broPositions.entries) {
      print("Notifying listeners for bro ID: ${entry.key} with location: ${entry.value}");
      int broId = entry.key;
      LatLng location = entry.value;
      for (final listener in _listeners) {
        listener(broId, location, false);
      }
    }
  }

  startSharingAll(Me me) async {
    print("start sharing all?");
    // Check if I'm sharing at the moment.
    // List<DateTimeWithBroupId>? endTimeShares = await SecureStorage().getDateTimeWithIds();
    List<LocationSharingData>? endTimeShares = await Storage().getAllActiveLocationSharing();
    if (endTimeShares != null) {
      List<LocationSharingData> timeShareMe = endTimeShares.where((share) => share.meSharing).toList();
      List<LocationSharingData> timeShareBros = endTimeShares.where((share) => !share.meSharing).toList();
      for (LocationSharingData endTimeShare in timeShareMe) {
        int broupId = endTimeShare.broupId;
        DateTime endTime = endTimeShare.dateTime.toLocal();
        print("start sharing $broupId $endTime");
        print("now time ${DateTime.now().toLocal()}");
        print("if statement ${endTime.isAfter(DateTime.now().toLocal())}");
        if (DateTime.now().toLocal().isAfter(endTime)) {
          // Now is after the endtime so the sharing is over.
          print("removing $broupId");
          if (endTimeShareMe.containsKey(broupId)) {
            endTimeShareMe.remove(broupId);
          }
          Storage().removeLocationSharing(me.id, broupId, true);
        } else {
          print("start sharing $broupId");
          startSharing(me, broupId, endTime);
        }
      }
      // Check if other bros are sharing
      for (LocationSharingData endTimeShareBro in timeShareBros) {
        int broId = endTimeShareBro.broId;
        int broupId = endTimeShareBro.broupId;
        DateTime endTime = endTimeShareBro.dateTime.toLocal();
        print("bro start sharing $broupId $endTime");
        print("bro now time ${DateTime.now().toLocal()}");
        print("bro if statement ${endTime.isAfter(DateTime.now().toLocal())}");
        if (DateTime.now().toLocal().isAfter(endTime)) {
          // no longer sharing, so remove the bro entry from the list
          await Storage().removeLocationSharing(broId, broupId, false);
        } else {
          if (!endTimeShareBroTimers.containsKey(broupId)) {
            endTimeShareBroTimers[broupId] = {};
          }
          if (endTimeShareBroTimers[broupId]![broId] != null) {
            endTimeShareBroTimers[broupId]![broId]!.cancel();
          }
          endTimeShareBroTimers[broupId]![broId] = Timer(Duration(milliseconds: endTime.toLocal().difference(DateTime.now().toLocal()).inMilliseconds), () async {
            print("End time reached for bro sharing. $broupId");
            await broShareTimeReached(endTimeShareBro.dateTime, endTimeShareBro.broupId, endTimeShareBro.broId);
          });
        }
      }
    }
  }

  broShareTimeReached(DateTime dateTime, int broupId, int broId) async {
    await Storage().removeLocationSharing(broId, broupId, false);
    print("bro share time reached $broupId - $broId");
    endTimeShareBroTimers[broupId]!.remove(broId);
    if (broPositions.containsKey(broId)) {
      broPositions.remove(broId);
    }
    if (broMarkerIcon.containsKey(broId)) {
      broMarkerIcon.remove(broId);
    }
    for (final listener in _listeners) {
      listener(broId, null, true);
    }
  }

  startEndTimeBroTimer(DateTime endTime, int broupId, int broId) {
    if (!endTimeShareBroTimers.containsKey(broupId)) {
      endTimeShareBroTimers[broupId] = {};
    }
    if (endTimeShareBroTimers[broupId]![broId] != null) {
      endTimeShareBroTimers[broupId]![broId]!.cancel();
    }
    endTimeShareBroTimers[broupId]![broId] = Timer(Duration(milliseconds: endTime.toLocal().difference(DateTime.now().toLocal()).inMilliseconds), () async {
      print("End time reached for bro sharing. $broupId   $broId");
      // TODO: Test this new method
      await broShareTimeReached(endTime, broupId, broId);
    });
  }

  void startSharing(Me me, int broupId, DateTime endTime) async {
    print("Starting location sharing for bro ID: ${me.getId()} in broup ID: $broupId");
    await stopSharingLocation(me,  broupId, endTime);
    await Storage().addLocationSharing(
        broId: me.id,
        broupId: broupId,
        endTime: endTime,
        meSharing: true
    );
    endTimeShareMe[broupId] = endTime;

    _endTimeTimers[broupId]?.cancel();

    positionStream[broupId] = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update if user moves 10 meters
      ),
    );

    void _startInactivityTimer(int broupId) {
      print("Starting inactivity timer");
      _inactivityTimer[broupId]?.cancel();
      // TODO: Set the minutes back to 5.
      _inactivityTimer[broupId] = Timer(const Duration(minutes: 1), () {

        print("No movement for 1 minute, forcing update");
        Geolocator.getLastKnownPosition().then((Position? position) {
          if (position != null) {
            print("Forced update with position: ${position.latitude}, ${position.longitude}");
            SocketServices().updateLocation(
              me.getId(),
              broupId,
              position.latitude,
              position.longitude,
            );
          }else {
            print("Failed to get last known position");
          }
        }).catchError((e) {
          print("Error getting last known position: $e");
        });
        _startInactivityTimer(broupId); // Restart the timer after forced update
      });
    }

    _streamSubscription[broupId] = positionStream[broupId]!.listen((Position position) {
      print("Update because the bro moved to position: ${position.latitude}, ${position.longitude}");
      // Update location on movement
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
      print("End time reached for broup $broupId");
      stopSharingLocation(me, broupId, endTime);
    });
  }

  Future stopSharingLocation(Me me, int broupId, DateTime endTime) async {
    print("stopSharingLocation");
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
    // Also remove my position and marker
    await Storage().removeLocationSharing(me.id, broupId, true);
    if (broPositions.containsKey(me.id)) {
      broPositions.remove(me.id);
    }
    if (broMarkerIcon.containsKey(me.id)) {
      broMarkerIcon.remove(me.id);
    }
    for (final listener in _listeners) {
      listener(me.id, null, true);
    }
    return;
  }

  updateBroLocation(int broId, LatLng location) {
    print("Updating bro location for bro ID: $broId to position: ${location.latitude}, ${location.longitude}");
    broPositions[broId] = location;
    _notifyListenersBro(broId, location);
  }

  String? _errorMessage;
  Future<void> getLocation() async {
    // 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorMessage = "Location services are disabled. Please enable them in settings.";
      print(_errorMessage);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorMessage = "Location permissions are denied. Cannot fetch location.";
        print(_errorMessage);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _errorMessage = "Location permissions are permanently denied. Please enable them in app settings.";
      print(_errorMessage);
      return;
    }
    _errorMessage = null;
  }

  getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorMessage = "Location permissions are denied. Cannot fetch location.";
        print(_errorMessage);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _errorMessage = "Location permissions are permanently denied. Please enable them in app settings.";
      print(_errorMessage);
      return;
    }
  }
}

class LocationSharingData {
  late DateTime dateTime;
  late int broupId;
  late int broId;
  late bool meSharing;

  LocationSharingData(this.dateTime, this.broupId, this.broId, this.meSharing);

  LocationSharingData.fromDbMap(Map<String, dynamic> map) {
    broupId = map['broupId'];
    String endTimeString = map['endTime'];
    dateTime = DateTime.parse(endTimeString).toLocal();
    broId = map["broId"];
    meSharing = map["meSharing"] == 1;
  }
}
