import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../objects/bro.dart';
import '../../../utils/location_sharing.dart';
import '../../../utils/storage.dart';
import '../../../utils/utils.dart';


class LocationViewer extends StatefulWidget {
  final String locationData;
  final bool liveLocation;
  final int broupId;
  final Bro? bro;

  const LocationViewer({
    Key? key,
    required this.locationData,
    required this.liveLocation,
    required this.broupId,
    required this.bro,
  }) : super(key: key);

  @override
  State<LocationViewer> createState() => _LocationViewerState();
}

class _LocationViewerState extends State<LocationViewer> {

  late GoogleMapController mapController;
  late LatLng startPosition;
  late LocationSharing locationSharing;
  Map<int, Marker> locationMarkers = {};
  Map<int, Bro> liveLocationInformation = {};

  late Storage storage;

  @override
  void initState() {
    super.initState();
    locationSharing = LocationSharing();
    locationSharing.getPermission();
    storage = Storage();
    if (widget.liveLocation) {
      startPosition = stringToLatLng(widget.locationData.split(";")[0]);
      locationSharing.addLocationListener(_onLocationUpdate);
      locationSharing.getBroupLocationsInit(widget.broupId);
    } else {
      startPosition = stringToLatLng(widget.locationData);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadLocationMarker();
      });
    }
  }

  loadLocationMarker() async {
    BitmapDescriptor broIcon = BitmapDescriptor.defaultMarker;
    String broTitle = "bro location";
    String broSnippet = "shared location";
    if (widget.bro != null && widget.bro!.getAvatar() != null) {
      broIcon = await locationSharing.createCustomMarkerWithText(
          widget.bro!.getAvatar()!, widget.bro!.bromotion, 60, 60);
      broTitle = widget.bro!.getFullName();
    }
    locationMarkers[widget.bro!.id] = Marker(
        markerId: MarkerId('bro_${widget.bro!.id}_Location'),
        position: startPosition,
        icon: broIcon,
        infoWindow: InfoWindow(
            title: broTitle,
            snippet: broSnippet
        )
    );
    setState(() {});
  }

  void _onLocationUpdate(int broId, LatLng? location, bool remove) async {
    print("Got update!");
    if (remove) {
      // When the markers are set we use this flag to know when to remove the markers.
      if (locationMarkers.containsKey(broId)) {
        locationMarkers.remove(broId);
      }
    } else {
      // Here a location is available and we will update the markers.
      Marker? broMarker = await locationSharing.getBroMarker(widget.broupId, broId);
      if (broMarker != null) {
        print("got bro marker");
        locationMarkers[broId] = broMarker;
      } else {
        locationMarkers[broId] = Marker(
          markerId: MarkerId('bro_${broId}_Location'),
          position: location!,
        );
        print("New location: ${location.latitude}, ${location.longitude}");
      }
    }
    setState(() {});
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

  Widget currentLiveLocationInformation() {
    // TODO: Make this clickable and show a popup of all the bros sharing live location (like with emoji reactions)
    List<Widget> liveLocationInformationBros = [];
    if (!widget.liveLocation) {
      String locationInformation = "";
      if (widget.bro != null) {
        locationInformation = "${widget.bro!.getFullName()} sent this location!";
      }
      liveLocationInformationBros.add(
        RichText(
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: locationInformation,
            style: simpleTextStyle(),
          ),
        ),
      );
    } else {
      if (locationSharing.endTimeShareOfTheBros.containsKey(widget.broupId)) {
        Map<int, DateTime>? liveLocationBros = locationSharing.endTimeShareOfTheBros[widget.broupId];
        if (liveLocationBros != null) {
          for (int broShareId in liveLocationBros.keys) {
            if (liveLocationInformation.containsKey(broShareId) && liveLocationInformation[broShareId] != null) {
              Bro broShared = liveLocationInformation[broShareId]!;
              DateTime? endTime = liveLocationBros[broShareId];
              if (endTime != null) {
                liveLocationInformationBros.add(
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        avatarBox(
                            50,
                            50,
                            broShared.getAvatar()
                        ),
                        RichText(
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: "${broShared.getFullName()} is sharing location till ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}",
                          style: simpleTextStyle(),
                        ),
                      ),
                    ]
                    ),
                  ),
                );
              }
            } else {
              storage.fetchBro(broShareId).then((bro) {
                if (bro != null) {
                  setState(() {
                    liveLocationInformation[broShareId] = bro;
                    print("set bro, bro!");
                  });
                }
              });
            }
          }
        }
      }
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      color: Colors.black,
      child: SingleChildScrollView(
        child: Column(
            children: liveLocationInformationBros
        ),
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
                    target: startPosition,
                    zoom: 17.0,
                  ),
                  markers: locationMarkers.values.toSet(),
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
            currentLiveLocationInformation()
          ],
        ),
      ),
    );
  }
}
