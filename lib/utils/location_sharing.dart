import 'dart:async';

import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../objects/me.dart';
import '../objects/message.dart';
import '../services/auth/v1_5/auth_service_social_v1_5.dart';

typedef LocationUpdateCallback = void Function(int broId, LatLng location);

class LocationSharing {
  static final LocationSharing _instance = LocationSharing._internal();

  Stream<Position>? positionStream;
  Timer? _inactivityTimer;
  StreamSubscription<Position>? _streamSubscription;

  Map<int, LatLng> broPositions = {};
  final List<LocationUpdateCallback> _listeners = [];

  LocationSharing._internal() {
  }

  factory LocationSharing() {
    return _instance;
  }

  void addLocationListener(LocationUpdateCallback listener) {
    print("Adding Location listener");
    _listeners.add(listener);
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
          _notifyListeners(message.senderId, value);
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

  void _notifyListeners(int broId, LatLng location) {
    print("Notifying listeners $_listeners");
    for (final listener in _listeners) {
      listener(broId, location);
    }
  }

  void startSharing(Me me, int broupId) {
    print("Starting location sharing for bro ID: ${me.getId()} in broup ID: $broupId");
    stopSharingLocation();

    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update if user moves 10 meters
      ),
    );

    void _startInactivityTimer() {
      print("Starting inactivity timer");
      _inactivityTimer?.cancel();
      _inactivityTimer = Timer(const Duration(minutes: 1), () {

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
        _startInactivityTimer(); // Restart the timer after forced update
      });
    }

    _streamSubscription = positionStream!.listen((Position position) {
      print("Update because the bro moved to position: ${position.latitude}, ${position.longitude}");
      // Update location on movement
      SocketServices().updateLocation(
        me.getId(),
        broupId,
        position.latitude,
        position.longitude,
      );

      // Reset the inactivity timer
      _inactivityTimer?.cancel();
      _startInactivityTimer();
    });

    // Start the initial timer
    _startInactivityTimer();
  }

  void stopSharingLocation() {
    _streamSubscription?.cancel();
    _inactivityTimer?.cancel();
  }

  updateBroLocation(int broId, LatLng location) {
    print("Updating bro location for bro ID: $broId to position: ${location.latitude}, ${location.longitude}");
    broPositions[broId] = location;
    _notifyListeners(broId, location);
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

    // Position position = await Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.high,
    // ).timeout(const Duration(seconds: 10));
    //
    // _currentPosition = LatLng(position.latitude, position.longitude);
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
