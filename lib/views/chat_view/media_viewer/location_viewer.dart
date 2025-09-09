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
import '../../../utils/locator.dart';
import '../../../utils/navigation_service.dart';
import '../../../utils/settings.dart';
import '../../../utils/socket_services.dart';
import '../../../utils/storage.dart';
import '../../../utils/utils.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class LocationViewer extends StatefulWidget {
  final LatLng locationData;

  const LocationViewer({
    Key? key,
    required this.locationData,
  }) : super(key: key);

  @override
  State<LocationViewer> createState() => _LocationViewerState();
}

class _LocationViewerState extends State<LocationViewer> {

  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void backButtonFunctionality() {
    Navigator.pop(context);
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        backButtonFunctionality();
        break;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Color(0xff145C9E),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              backButtonFunctionality();
            },
          ),
          title: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Location Viewer",
                  style: TextStyle(color: Colors.white)
              )
          ),
          actions: [
            PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(value: 0, child: Text("Back to Chat")),
                ]
            ),
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: widget.locationData,
                    zoom: 17.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('messageLocation'),
                      position: widget.locationData,
                    ),
                  },
                  mapType: MapType.normal,
                  onCameraMove: (CameraPosition position) {
                    print("camera moved");
                  },
                  onCameraIdle: () {
                    print("camera idle");
                  },
                  onTap: (LatLng pos) {
                    print("map tapped");
                  },
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
