import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:brocast/objects/data_type.dart';
import 'package:brocast/utils/location_sharing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:brocast/services/auth/v1_5/auth_service_social_v1_5.dart';
import 'package:brocast/views/chat_view/media_viewer/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../../objects/message.dart';
import '../../../objects/bro.dart';
import 'dart:ui';

import '../../../objects/broup.dart';
import '../../../objects/me.dart';
import '../../../services/auth/v1_4/auth_service_social.dart';
import '../../../utils/settings.dart';
import '../../../utils/storage.dart';
import '../../../utils/utils.dart';
import '../media_viewer/location_viewer.dart';
import '../media_viewer/video_viewer.dart';
import '../waved_audio/waved_audio_player.dart';

class MessageTile extends StatefulWidget {
  final Message message;
  final bool private;
  final Bro? bro;
  final bool broAdded;
  final bool broAdmin;
  final bool myMessage;
  final bool userAdmin;
  final Message? repliedMessage;
  final Bro? repliedBro;
  final GlobalKey animationKey;
  final void Function(int, int) messageHandling;
  final void Function(Message, Offset) messageLongPress;

  MessageTile({
    required Key key,
    required this.message,
    required this.private,
    required this.bro,
    required this.broAdded,
    required this.broAdmin,
    required this.myMessage,
    required this.userAdmin,
    required this.repliedMessage,
    required this.repliedBro,
    required this.animationKey,
    required this.messageHandling,
    required this.messageLongPress
  }) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> with SingleTickerProviderStateMixin {

  VideoPlayerController? _videoController;
  bool videoControllerInitialized = false;
  bool audioControllerInitialized = false;

  bool isLoading = false;
  bool audioIsPaused = true;
  String? audioFilePath;

  LocationSharing? locationSharing;
  Map<int, Marker> locationMarkers = {};
  Set<Marker> mapMarkers = {};

  selectMessage(BuildContext context) async {
    if ((widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) || widget.message.dataType != null) {
      setState(() {
        widget.message.clicked = !widget.message.clicked;
      });
      if (widget.message.clicked) {
        if (widget.message.dataType != null && !widget.message.dataIsReceived) {
          // There should be data in this message, but it is not yet received from the server yet.
          isLoading = true;
          AuthServiceSocialV15().getMessageData(widget.message.broupId, widget.message.messageId).then((messageDataResponse) async {
            // For a video we first want to load the video controller
            if (widget.message.dataType != DataType.video.value) {
              isLoading = false;
            }
            // Audio and images are loaded immediately.
            if (messageDataResponse != null) {
              // If the data is present, we set the flag to received
              widget.message.dataIsReceived = true;
              widget.message.data = await saveMediaData(messageDataResponse, widget.message.dataType!);
              if (widget.message.dataType == DataType.video.value) {
                _initializeVideoController();
              } else if (widget.message.dataType == DataType.audio.value) {
                _initializeAudioController();
              }
              Storage().updateMessage(widget.message);
              setState(() {
                messageData = getMessageData(widget.message.data!);
              });
              // We have now actually received the full message, so indicate as such.
              AuthServiceSocial().receivedMessageSingle(widget.message.broupId, widget.message.messageId).then((value) {
                if (value) {
                  // do something special on success?
                }
              });
            }
          });
        } else {
          if (widget.message.dataType == DataType.video.value) {
            _initializeVideoController();
          } else if (widget.message.dataType == DataType.audio.value) {
            _initializeAudioController();
          } else if (widget.message.dataType == DataType.location.value) {
            locationSharing = LocationSharing();
            locationSharing!.getPermission();
            LatLng messageLocation = stringToLatLng(widget.message.data!);
            BitmapDescriptor broIcon = BitmapDescriptor.defaultMarker;
            String broTitle = "bro location";
            String broSnippet = "shared location";
            if (widget.bro != null && widget.bro!.getAvatar() != null) {
              broIcon = await locationSharing!.createCustomMarkerWithText(
                  widget.bro!.getAvatar()!, widget.bro!.bromotion, 60, 60);
              broTitle = widget.bro!.getFullName();
            }
            locationMarkers[widget.message.senderId] = Marker(
              markerId: MarkerId('bro_${widget.message.senderId}_Location'),
              position: messageLocation,
              icon: broIcon,
              infoWindow: InfoWindow(
                  title: broTitle,
                  snippet: broSnippet
              )
            );
            setState(() {});
          } else if (widget.message.dataType == DataType.liveLocation.value) {
            locationSharing = LocationSharing();
            locationSharing!.getPermission();
            locationSharing!.addLocationListener(_onLocationUpdate);
            locationSharing!.getBroupLocationsInit(widget.message.broupId);
            setState(() {
            });
          }
        }
      } else {
        if (widget.message.dataType == DataType.video.value) {
          setState(() {
            _videoController!.pause();
          });
        }
        if (widget.message.dataType == DataType.location.value || widget.message.dataType == DataType.liveLocation.value) {
          if (locationSharing != null) {
            locationSharing!.removeLocationListener(_onLocationUpdate);
          }
        }
      }
    }
  }

  late final controller = SlidableController(this);
  bool replying = false;

  Uint8List? messageData;

  @override
  void initState() {
    super.initState();
    // If the slide is made we want to trigger the replied to functionality.
    controller.endGesture.addListener(() {
      // We close the controller, which will put the message back in its original position
      // The replied to functionality is handled in the parent widget
      if (controller.animation.value > 0.1) {
        replying = true;
      }
      controller.close();
    });

    controller.direction.addListener(() {
      // 0 means stopped moving. If the replied to was triggered
      // and it is no longer moving, we want to trigger the replied to functionality
      if (replying && controller.direction.value == 0) {
        replyToMessage();
      }
    });
  }

  void _initializeAudioController() async {
    if (widget.message.data != null && widget.message.dataType == DataType.audio.value && !audioControllerInitialized) {
      audioControllerInitialized = true;
      final file = File(widget.message.data!);
      final tempDirectory = await getTemporaryDirectory();
      String newFilePath = '${tempDirectory.path}/previewAudio_${widget.message.messageId}.mp3';
      final fileView = await file.copy(newFilePath);
      audioFilePath = fileView.path;

      setState(() {});
    }
  }

  void _initializeVideoController() async {
    if (widget.message.data != null && widget.message.dataType == DataType.video.value && !videoControllerInitialized) {
      videoControllerInitialized = true;
        final file = File(widget.message.data!);
        final tempDirectory = await getTemporaryDirectory();
        // The video will be stored and loaded in a hidden folder with the
        // default name which is reused for each new video.
        String newFilePath = '${tempDirectory.path}/previewVideo.mp4';
        final fileView = await file.copy(newFilePath);
        _videoController = VideoPlayerController.file(
            fileView,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true)
        )
          ..initialize().then((_) {
            setState(() {
              isLoading = false;
            });
            _videoController?.setLooping(true);
            _videoController?.pause();
          });
    }
  }

  Uint8List getMessageDataContent() {
    if (messageData == null && widget.message.data != null) {
      messageData = getMessageData(widget.message.data!);
    }
    if (messageData == null) {
      // return the image `not_found.png` in the assets images folder
      // TODO: Maybe something better? It might be loading so not found is not the best option
      return Settings().notFoundImage;
    }
    return messageData!;
  }

  @override
  void dispose() {
    if (widget.message.dataType != null) {
      if (widget.message.dataType == DataType.video.value) {
        _videoController?.pause();
      }
    }
    if (locationSharing != null) {
      locationSharing!.removeLocationListener(_onLocationUpdate);
    }
    _videoController?.dispose();
    controller.endGesture.removeListener(() {});
    replying = false;
    super.dispose();
  }

  void _onLocationUpdate(int broId, LatLng? location, bool remove) async {
    Broup? chat;
    Me? me = Settings().getMe();
    if (me != null) {
      for (Broup meBroup in me.broups) {
        if (meBroup.broupId == widget.message.broupId) {
          chat = meBroup;
          break;
        }
      }
    }
    if (chat == null) {
      chat = await Storage().fetchBroup(widget.message.broupId);
    }

    if (chat != null) {
      if (chat.broIds.contains(broId)) {
        if (remove) {
          // When the markers are set we use this flag to know when to remove the markers.
          if (locationMarkers.containsKey(broId)) {
            locationMarkers.remove(broId);
          }
        } else {
          // Here a location is available and we will update the markers.
          Marker? broMarker = await locationSharing!.getBroMarker(widget.message.broupId, broId);
          if (broMarker != null) {
            locationMarkers[broId] = broMarker;
          } else {
            locationMarkers[broId] = Marker(
              markerId: MarkerId('bro_${broId}_Location'),
              position: location!,
            );
          }
        }
        setState(() {
          Set<Marker> locationMarkersNow = locationMarkers.values.toSet();
          mapMarkers = locationMarkersNow;
        });
      }
    }
  }

  Color getBorderColour() {
    Color borderColour = widget.myMessage
        ? Color(0xFF009E00)
        : Color(0xFF0060BB);

    if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
      borderColour = Colors.yellow;
    }

    if (widget.message.dataType == DataType.image.value) {
      borderColour = Colors.red;
    } else if (widget.message.dataType == DataType.video.value) {
      borderColour = Colors.pinkAccent[100]!;
    } else if (widget.message.dataType == DataType.audio.value) {
      borderColour = Colors.purpleAccent;
    } else if (widget.message.dataType == DataType.location.value) {
      borderColour = Colors.tealAccent;
    } else if (widget.message.dataType == DataType.liveLocation.value || widget.message.dataType == DataType.liveLocationStop.value) {
      borderColour = Colors.cyanAccent;
    }

    return borderColour;
  }

  clickedEmojiReaction() {
    widget.messageHandling(3, widget.message.messageId);
  }

  replyToMessage() {
    widget.messageHandling(1, widget.message.messageId);
  }

  clickedReplyMessage() {
    if (widget.message.repliedTo != null) {
      // It's possible that the message is not on your phone anymore
      // In this case we have an empty message with messageId 0 and info set to true
      // We want to ignore this
      if (widget.message.repliedMessage != null && widget.message.repliedMessage!.messageId != 0 && !widget.message.repliedMessage!.info) {
        widget.messageHandling(2, widget.message.repliedTo!);
      }
    }
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  goToMediaViewer() {
    if (widget.message.dataType == DataType.image.value) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageViewer(
            key: UniqueKey(),
            image: getMessageDataContent(),
          ),
        ),
      ).then((_) { });
    } else if (widget.message.dataType == DataType.video.value) {
      if (widget.message.data != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                VideoViewer(
                    key: UniqueKey(),
                    videoFilePath: widget.message.data!
                ),
          ),
        ).then((_) {});
      }
    } else if (widget.message.dataType == DataType.location.value) {
      if (widget.message.data != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                LocationViewer(
                  key: UniqueKey(),
                  locationData: widget.message.data!,
                  liveLocation: false,
                  broupId: widget.message.broupId,
                  bro: widget.bro,
                  myMessage: widget.myMessage,
                  currentMessage: null,
                ),
          ),
        ).then((_) {});
      }
    } else if (widget.message.dataType == DataType.liveLocation.value) {
      if (widget.message.data != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                LocationViewer(
                  key: UniqueKey(),
                  locationData: widget.message.data!,
                  liveLocation: true,
                  broupId: widget.message.broupId,
                  bro: null,
                  myMessage: widget.myMessage,
                  currentMessage: widget.message,
                ),
          ),
        ).then((_) {});
      }
    }
  }

  Widget viewImageButton() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: InkWell(
              onTap: () {
                goToMediaViewer();
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.remove_red_eye,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ]
    );
  }

  Widget repliedToView() {
    Message? repliedToMessage = widget.repliedMessage;
    if (repliedToMessage == null) {
      return Container();
    } else {
      String replySenderName = "Message not available";
      if (widget.repliedBro != null) {
        replySenderName = widget.repliedBro!.getFullName();
      }
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            clickedReplyMessage();
          },
          splashColor: const Color(0x56e4e4e4),
          child: Container(
            color: Colors.black.withAlpha(64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.reply,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      replySenderName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                if (repliedToMessage.body != "")
                  Text(
                    repliedToMessage.body,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }

  double getOptionWidth(String messageContent, TextStyle textStyle) {
    final textSpan = TextSpan(
        text: messageContent,
        style: textStyle
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout();

    final textWidth = textPainter.size.width;

    // Add the padding and some final adjustments
    return textWidth + 8;
  }

  double getMessageWidgetWidth() {
    if (widget.message.clicked) {
      if (widget.message.dataType != null) {
        return MediaQuery.of(context).size.width;
      }
    }
    double widgetWidth = getOptionWidth(widget.message.body, simpleTextStyle());
    if (widget.message.clicked) {
      // If it is clicked we want to check which is larger, the body or the textMessage
      // The width is the largest of the two
      // Or, if it has data than the width is maximum
      if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
        double textMessageWidth = getOptionWidth(widget.message.textMessage!, simpleTextStyle());
        if (textMessageWidth > widgetWidth) {
          widgetWidth = textMessageWidth;
        }
      }
    }
    if (widget.message.repliedMessage != null) {
      Message repliedToMessage = widget.message.repliedMessage!;
      TextStyle replyTextStyle = TextStyle(color: Colors.white);
      double repliedToBodyWidth = getOptionWidth(repliedToMessage.body, replyTextStyle);
      String replySenderName = "Message not available";
      if (widget.repliedBro != null) {
        replySenderName = widget.repliedBro!.getFullName();
      }
      double repliedToNameWidth = getOptionWidth(replySenderName, replyTextStyle);
      // Add the reply icon width
      repliedToNameWidth += 20;
      if (repliedToBodyWidth > repliedToNameWidth) {
        if (repliedToBodyWidth > widgetWidth) {
          widgetWidth = repliedToBodyWidth;
        }
      } else {
        if (repliedToNameWidth > widgetWidth) {
          widgetWidth = repliedToNameWidth;
        }
      }
    }
    return widgetWidth;
  }

  late GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
      if (locationSharing != null) {
        await locationSharing!.sendMessageStopSharing(me, widget.message.broupId, widget.message);
        await locationSharing!.stopSharingLocation(me, widget.message.broupId);
      }
    }
  }

  Widget stopLiveSharingButton() {
    if (widget.message.dataType != DataType.liveLocation.value) {
      return Container();
    }
    if (locationSharing == null) {
      return Container();
    }
    if (!locationSharing!.endTimeShareMe.containsKey(widget.message.broupId)) {
      return Container();
    }
    if (!widget.myMessage) {
      return Container();
    }
    DateTime? endTimeMe = locationSharing!.endTimeShareMe[widget.message.broupId];
    if (endTimeMe == null) {
      return Container();
    }
    if (DateTime.now().toLocal().isAfter(endTimeMe.toLocal())) {
      return Container();
    }
    // Still some sharing being done
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
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
        ),
      ]
    );
  }

  Widget currentLiveLocationInformation() {
    List<Widget> liveLocationInformationBros = [];
    if (widget.message.dataType != DataType.liveLocation.value) {
      String locationInformation = "";
      if (widget.myMessage) {
        locationInformation = "You sent this location!";
      } else if (widget.bro != null) {
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
      if (locationSharing != null) {
        if (locationSharing!.liveSharingBroInformation.containsKey(widget.message.broupId)) {
          Map<int, String>? liveLocationBros = locationSharing!.liveSharingBroInformation[widget
              .message.broupId];
          if (liveLocationBros != null) {
            for (String broShareInformation in liveLocationBros.values) {
              liveLocationInformationBros.add(
                RichText(
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: broShareInformation,
                    style: simpleTextStyle(),
                  ),
                ),
              );
            }
          }
        }
      }
      if (liveLocationInformationBros.isEmpty) {
        if (widget.bro != null) {
          String infoShare = "Bro ${widget.bro!.getFullName()} was sharing their Live Location";
          if (widget.myMessage) {
            infoShare = "You were sharing your Live Location";
          }
          liveLocationInformationBros.add(
            RichText(
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: infoShare,
                style: simpleTextStyle(),
              ),
            ),
          );
        }
      }
    }
    return Column(
        mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: liveLocationInformationBros
    );
  }

  Widget getLocationContent() {
    if (widget.message.dataType == null) {
      return Container();
    }
    LatLng? messageLocation;
    if (widget.message.dataType == DataType.location.value) {
      messageLocation = stringToLatLng(widget.message.data!);
    } else if (widget.message.dataType == DataType.liveLocation.value) {
      if (locationMarkers.values.toSet().isNotEmpty) {
        messageLocation = locationMarkers.values.toSet().first.position;
      } else {
        // After live location is done we show where it started as placeholder.
        messageLocation = stringToLatLng(widget.message.data!.split(";")[0]);
      }
    }
    if (messageLocation == null) {
      return Container();
    }
    List<Widget> commonChildren = [
      viewImageButton(),
      repliedToView(),
      currentLiveLocationInformation(),
      Text(
          widget.message.body,
          style: simpleTextStyle()
      ),
      GestureDetector(
        onTap: () {},
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height/2,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: messageLocation,
              zoom: calculateZoomLevel(500),
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            markers: mapMarkers,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
              ),
            }.toSet(),
            onCameraMove: (CameraPosition position) {
            },
            onCameraIdle: () {
            },
            onTap: (LatLng pos) {
              selectMessage(context);
            },
            onLongPress: (LatLng pos) {
              Offset offset = Offset(
                MediaQuery.of(context).size.width / 2,
                MediaQuery.of(context).size.height / 2,
              );
              onLongPressMessage(context, offset);
            }
          ),
        ),
      ),
      stopLiveSharingButton(),
    ];

    if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
      commonChildren.add(
          Linkify(
              onOpen: _onOpen,
              text: widget.message.textMessage!,
              linkStyle: TextStyle(color: Color(0xffFFC0CB), fontSize: 18),
              style: simpleTextStyle()
          )
      );
    }
    return Column(
        mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: commonChildren
    );
  }

  Widget getAudioContent(double messageWidth) {
    List<Widget> commonChildren = [
      repliedToView(),
      Text(
          widget.message.body,
          style: simpleTextStyle()
      ),
      isLoading || audioFilePath == null
          ? CircularProgressIndicator()
          : Container(
              child: WavedAudioPlayer(
                key: ValueKey(widget.message.messageId),
                filePath: audioFilePath!,
                messageId: widget.message.messageId,
                waveWidth: messageWidth - 4,
                waveHeight: 60,
                barWidth: 3,
              )
            ),
    ];

    if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
      commonChildren.add(
          Linkify(
              onOpen: _onOpen,
              text: widget.message.textMessage!,
              linkStyle: TextStyle(color: Color(0xffFFC0CB), fontSize: 18),
              style: simpleTextStyle()
          )
      );
    }

    return Column(
        mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: commonChildren
    );
  }

  Widget getVideoContent() {
    final commonChildren = [
      viewImageButton(),
      repliedToView(),
      Text(
          widget.message.body,
          style: simpleTextStyle()
      ),
      isLoading
          ? CircularProgressIndicator()
          : _videoController != null && _videoController!.value.isInitialized
          ? AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      )
          : CircularProgressIndicator(),
      ElevatedButton(
        onPressed: () {
          setState(() {
            _videoController!.value.isPlaying
                ? _videoController!.pause()
                : _videoController!.play();
          });
        },
        child: _videoController != null && _videoController!.value.isInitialized ? Icon(
          _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ) : Container(),
      ),
    ];

    if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
      commonChildren.add(
          Linkify(
              onOpen: _onOpen,
              text: widget.message.textMessage!,
              linkStyle: TextStyle(color: Color(0xffFFC0CB), fontSize: 18),
              style: simpleTextStyle()
          )
      );
    }

    return Column(
        mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: commonChildren
    );
  }

  Widget getImageContent() {
    final commonChildren = [
      viewImageButton(),
      repliedToView(),
      Text(
          widget.message.body,
          style: simpleTextStyle()
      ),
      isLoading
          ? CircularProgressIndicator()
          : Image.memory(getMessageDataContent()),
    ];

    if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
      commonChildren.add(
          Linkify(
              onOpen: _onOpen,
              text: widget.message.textMessage!,
              linkStyle: TextStyle(color: Color(0xffFFC0CB), fontSize: 18),
              style: simpleTextStyle()
          )
      );
    }

    return Column(
        mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: commonChildren
    );
  }

  getTextContent() {
    return Column(
        mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          repliedToView(),
          Text(
              widget.message.body,
              style: simpleTextStyle()
          ),
          Linkify(
              onOpen: _onOpen,
              text: widget.message.textMessage!,
              linkStyle: TextStyle(color: Color(0xffFFC0CB), fontSize: 18),
              style: simpleTextStyle()
          ),
        ]
    );
  }

  getBodyContent() {
    return Column(
        mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          repliedToView(),
          Text(
              widget.message.body,
              style: simpleTextStyle()
          ),
        ]
    );
  }

  Widget getMessageContent(double messageWidth) {
    Widget content;
    if (widget.message.clicked) {
      if (widget.message.dataType == DataType.image.value) {
        content = getImageContent();
      } else if (widget.message.dataType == DataType.video.value) {
        content = getVideoContent();
      } else if (widget.message.dataType == DataType.audio.value) {
        content = getAudioContent(messageWidth);
      } else if (widget.message.dataType == DataType.location.value) {
        content = getLocationContent();
      } else if (widget.message.dataType == DataType.liveLocation.value) {
        content = getLocationContent();
      } else if (widget.message.dataType == DataType.liveLocationStop.value) {
        // The location share stop content is basically a text message
        content = getTextContent();
      } else {
        content = getTextContent();
      }
    } else {
      content = getBodyContent();
    }

    return AnimatedSize(
      key: widget.animationKey,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Container(
        width: messageWidth,
        child: content,
      ),
    );
  }

  Widget informationMessage() {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: 10, maxWidth: MediaQuery.of(context).size.width),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0x55D3D3D3),
                    const Color(0x55C0C0C0)
                  ]),
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.message.body,
                      style: TextStyle(
                          color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]
    );
  }

  Widget senderIndicator(double messageWidth) {
    return Container(
      width: messageWidth,
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.bro != null ? widget.bro!.getFullName() : "",
                  style: TextStyle(
                      color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget broTimeIndicator(double messageWidth) {
    return Container(
      width: messageWidth,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: DateFormat('HH:mm')
                      .format(widget.message.getTimeStamp()),
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
                WidgetSpan(child: Container()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget myTimeIndicator(double messageWidth) {
    return Container(
      width: messageWidth,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: DateFormat('HH:mm')
                      .format(widget.message.getTimeStamp()),
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
                widget.message.isRead == 2
                    ? WidgetSpan(
                    child: Icon(Icons.done,
                        color: Colors.white54, size: 18))
                    : WidgetSpan(
                    child: Icon(Icons.done_all,
                        color: widget.message.hasBeenRead()
                            ? Colors.blue
                            : Colors.white54,
                        size: 18))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget timeIndicator(double messageWidth) {
    return widget.myMessage ? myTimeIndicator(messageWidth) : broTimeIndicator(messageWidth);
  }

  Widget emojiReactionWidget(double messageWidth) {
    if (widget.message.getEmojiReaction().isEmpty) {
      return Container();
    } else {
      final ScrollController scrollController = ScrollController();
      List<String> emojiReactions = widget.message.getEmojiReaction().values.toList();
      double emojiWidth = 24;
      double totalEmojiWidth = 24;
      if (emojiReactions.length > 1) {
        totalEmojiWidth += (emojiReactions.length - 1) * 16.0;
      }

      double maxPosition = totalEmojiWidth - (messageWidth + 24);
      bool disableScrolling = totalEmojiWidth < (messageWidth + 24);
      scrollController.addListener(() {
        if (scrollController.position.pixels > maxPosition) {
          scrollController.jumpTo(maxPosition);
        }
      });
      double actualWidth = messageWidth + 24;
      double difference = 0;
      if (totalEmojiWidth < actualWidth) {
        difference = actualWidth - totalEmojiWidth;
        actualWidth = totalEmojiWidth;
      }
      return Positioned(
        bottom: 0,
        right: widget.myMessage ? 12 + difference : null,
        left: widget.myMessage ? null : 12 + difference,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              clickedEmojiReaction();
            },
            child: Container(
              height: emojiWidth,
              width: actualWidth,
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                physics: disableScrolling ? NeverScrollableScrollPhysics() : null,
                child: Row(
                  children: List.generate(emojiReactions.length, (index) {
                    return Transform.translate(
                      offset: Offset(-index * 8.0, 0),
                      child: Container(
                        width: emojiWidth,
                        height: emojiWidth,
                        child: Text(
                          emojiReactions[index],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget messageBox(bool broup) {
    // The width that is bound by the message content.
    // Used for the messageBox and the emojiReactionWidget
    double messageWidth = getMessageWidgetWidth();
    double maximumMessageWith = MediaQuery.of(context).size.width - 24 - 24;
    if (broup) {
      // Subtract the width of the avatar
      maximumMessageWith -= 50;
    }
    if (messageWidth > maximumMessageWith) {
      messageWidth = maximumMessageWith;
    }
    return Stack(
      children: [
        Align(
          alignment: widget.myMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: widget.message.getEmojiReaction().length == 0 ? 12 : 20
            ),
            decoration: BoxDecoration(
                border: Border.all(
                  color: getBorderColour(),
                  width: 2,
                ),
                color: widget.myMessage
                    ? Color(0xFF009E00)
                    : Color(0xFF0060BB),
                borderRadius: widget.myMessage
                    ? BorderRadius.only(
                    topLeft: Radius.circular(42),
                    bottomRight: Radius.circular(42),
                    bottomLeft: Radius.circular(42))
                    : BorderRadius.only(
                    bottomLeft: Radius.circular(42),
                    topRight: Radius.circular(42),
                    bottomRight: Radius.circular(42))),
            child: Container(
                child: getMessageContent(messageWidth)
            ),
          ),
        ),
        emojiReactionWidget(messageWidth)
      ],
    );
  }

  Widget regularMessageBroup() {
    double avatarSize = 50;
    double messageWidth = MediaQuery.of(context).size.width - avatarSize;
    Uint8List? broAvatar = null;
    if (widget.bro != null) {
      broAvatar = widget.bro!.getAvatar();
    }
    return Container(
      margin: EdgeInsets.only(top: 6),
      child: Container(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: avatarSize,
                  child: widget.myMessage ? Container() : avatarBox(avatarSize, avatarSize, broAvatar)
              ),
              Material(
                child: Column(
                    children: [
                      widget.myMessage
                          ? Container()
                          : senderIndicator(messageWidth),
                      Container(
                        width: messageWidth,
                        alignment: widget.myMessage
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        child: GestureDetector(
                          onLongPressStart: (details) =>
                              onLongPressMessage(context, details.globalPosition),
                          onTap: () async {
                            selectMessage(context);
                          },
                          child: messageBox(true),
                        ),
                      ),
                      timeIndicator(messageWidth),
                    ]
                ),
                color: Colors.transparent,
              ),
            ]
        ),
      ),
    );
  }

  Widget regularMessageBro() {
    double messageWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(top: 6),
      child: Container(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                child: Column(
                    children: [
                      Container(
                        width: messageWidth,
                        alignment: widget.myMessage
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        child: GestureDetector(
                          onLongPressStart: (details) =>
                              onLongPressMessage(context, details.globalPosition),
                          onTap: () {
                            selectMessage(context);
                          },
                          child: messageBox(false),
                        ),
                      ),
                      timeIndicator(messageWidth),
                    ]
                ),
                color: Colors.transparent,
              ),
            ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.message.isInformation()
        ? informationMessage()
        : Slidable(
      controller: controller,
      key: UniqueKey(),
      closeOnScroll: true,
      // The start action pane is the one at the left or the top side.
      startActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              replyToMessage();
            },
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            icon: Icons.reply,
          ),
        ],
      ),
      child: widget.private ? regularMessageBro() : regularMessageBroup(),
    );
  }

  void onLongPressMessage(BuildContext context, Offset pressPosition) {
    widget.messageLongPress(widget.message, pressPosition);
  }
}
