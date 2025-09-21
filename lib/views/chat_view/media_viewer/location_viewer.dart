import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../objects/bro.dart';
import '../../../objects/me.dart';
import '../../../objects/message.dart';
import '../../../utils/location_sharing.dart';
import '../../../utils/settings.dart';
import '../../../utils/storage.dart';
import '../../../utils/utils.dart';
import 'location_sharing_overview.dart';


class LocationViewer extends StatefulWidget {
  final String locationData;
  final bool liveLocation;
  final int broupId;
  final Bro? bro;
  final bool myMessage;
  final Message? currentMessage;

  const LocationViewer({
    Key? key,
    required this.locationData,
    required this.liveLocation,
    required this.broupId,
    required this.bro,
    required this.myMessage,
    required this.currentMessage,
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
  bool showLocationSharingOverview = false;
  Map<int, LocationSharingOverviewData> locationSharingDataList = {};

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
    Storage().fetchBroup(widget.broupId).then((broup) async {
      if (broup != null) {
        if (broup.broIds.contains(broId)) {
          if (remove) {
            // When the markers are set we use this flag to know when to remove the markers.
            if (locationMarkers.containsKey(broId)) {
              locationMarkers.remove(broId);
            }
            if (locationSharingDataList.containsKey(broId)) {
              locationSharingDataList.remove(broId);
            }
            if (liveLocationInformation.containsKey(broId)) {
              liveLocationInformation.remove(broId);
            }
          } else {
            // Here a location is available and we will update the markers.
            Marker? broMarker = await locationSharing.getBroMarker(widget.broupId, broId);
            if (broMarker != null) {
              locationMarkers[broId] = broMarker;
            } else {
              locationMarkers[broId] = Marker(
                markerId: MarkerId('bro_${broId}_Location'),
                position: location!,
              );
            }
          }
          setState(() {});
        }
      }
    });
  }


  @override
  void dispose() {
    locationSharing.removeLocationListener(_onLocationUpdate);
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

  tappedLiveLocationShareBox() {
    setState(() {
      showLocationSharingOverview = true;
    });
  }

  bool currentlySharing() {
    if (widget.bro != null) {
      // Regular location view.
      return false;
    }
    if (!locationSharing.endTimeShareMe.containsKey(widget.broupId)) {
      return false;
    }
    DateTime? endTimeMe = locationSharing.endTimeShareMe[widget.broupId];
    if (endTimeMe == null) {
      return false;
    }
    if (DateTime.now().toLocal().isAfter(endTimeMe.toLocal())) {
      return false;
    }
    return true;
  }


  showDialogStopSharing(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Stop Sharing live location?"),
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Are you sure?\nThis will stop sharing your live location with this broup!",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Stop Sharing"),
                onPressed: () {
                  Navigator.of(context).pop();
                  stopLiveSharing();
                },
              ),
            ],
          );
        });
  }

  stopLiveSharing() async {
    Me? me = Settings().getMe();
    if (me != null) {
      if (widget.currentMessage != null) {
        await locationSharing.sendMessageStopSharing(me, widget.broupId, widget.currentMessage!);
        await locationSharing.stopSharingLocation(me, widget.broupId);
        backButtonFunctionality();
      }
    }
  }

  Widget currentLiveLocationInformation() {
    double liveLocationHeight = 0.0;
    List<Widget> liveLocationInformationBros = [];
    if (!widget.liveLocation) {
      if (widget.bro != null) {
        String locationInformation = "";
        if (widget.myMessage) {
          locationInformation = "You sent this location!";
        } else {
          locationInformation = "${widget.bro!.getFullName()} sent this location!";
        }
        liveLocationInformationBros.add(
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
                children: [
                  avatarBox(
                      50,
                      50,
                      widget.bro!.getAvatar()
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: locationInformation,
                      style: simpleTextStyle(),
                    ),
                  ),
                ]
            ),
          ),
        );
        if (liveLocationHeight == 0) {
          liveLocationHeight = 50;
        } else if (liveLocationHeight == 50) {
          liveLocationHeight = 80;
        }
      }
    } else {
      if (locationSharing.endTimeShareOfTheBros.containsKey(widget.broupId)) {
        Map<int, DateTime>? liveLocationBros = locationSharing.endTimeShareOfTheBros[widget.broupId];
        if (liveLocationBros != null) {
          for (int broShareId in liveLocationBros.keys) {
            DateTime? endTime = liveLocationBros[broShareId];
            if (endTime != null) {
              if (liveLocationInformation.containsKey(broShareId) && liveLocationInformation[broShareId] != null) {
                Bro broShared = liveLocationInformation[broShareId]!;
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
                  if (liveLocationHeight == 0) {
                    liveLocationHeight = 50;
                  } else if (liveLocationHeight == 50) {
                    liveLocationHeight = 80;
                  }
                } else {
                  storage.fetchBro(broShareId).then((bro) {
                    if (bro != null) {
                      String locationString = "${bro.getFullName()} is sharing location till ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
                      setState(() {
                        liveLocationInformation[broShareId] = bro;
                        locationSharingDataList[broShareId] = LocationSharingOverviewData(bro: bro, locationInformation: locationString);
                      });
                    }
                  });
                }
            }
          }
        }
      }
    }

    Widget stopSharingButton = Container();
    if (currentlySharing()) {
      stopSharingButton = Container(
        width: MediaQuery.of(context).size.width,
        height: 30,
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: () {
            showDialogStopSharing(context);
          },
          child: Text("Stop Sharing"),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.liveLocation) {
                tappedLiveLocationShareBox();
              }
            },
            child: Container(
              height: liveLocationHeight + 2,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                    children: liveLocationInformationBros
                ),
              ),
            ),
          ),
          stopSharingButton,
        ]
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
                    zoom: calculateZoomLevel(500),
                  ),
                  markers: locationMarkers.values.toSet(),
                  mapType: MapType.normal,
                  onCameraMove: (CameraPosition position) {
                  },
                  onCameraIdle: () {
                  },
                  onTap: (LatLng pos) {
                  },
                )
              ),
            ),
            currentLiveLocationInformation(),
            if (showLocationSharingOverview)
              LocationSharingOverview(
                emojiOverviewDataList: locationSharingDataList.values.toList(),
                onOutsideTap: () {
                  setState(() {
                    showLocationSharingOverview = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
