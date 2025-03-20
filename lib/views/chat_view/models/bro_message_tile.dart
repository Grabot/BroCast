import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../objects/message.dart';
import '../../../utils/utils.dart';



class BroMessageTile extends StatefulWidget {
  final Message message;
  final bool myMessage;

  BroMessageTile(
      {required Key key, required this.message, required this.myMessage})
      : super(key: key);

  @override
  _BroMessageTileState createState() => _BroMessageTileState();
}

class _BroMessageTileState extends State<BroMessageTile> {

  var _tapPosition;
  bool isImage = false;

  selectMessage(BuildContext context) {
    if ((widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) || isImage) {
      setState(() {
        widget.message.clicked = !widget.message.clicked;
      });
    }
  }

  Image? broImage;

  @override
  void initState() {
    super.initState();
    if (widget.message.data != null && widget.message.data != "") {
      Uint8List decoded = base64.decode(widget.message.data!);
      broImage = Image.memory(decoded);
      isImage = true;
    }
  }

  Color getBorderColour() {
    // First we set the border to be the colour of the message
    // Which is the colour for a normal plain message without content
    Color borderColour = widget.myMessage
        ? Color(0xFF009E00)
        : Color(0xFF0060BB);
    // We check if there is a message content
    if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
      // If this is the case the border should be yellow, but only if it's not clicked
      if (!widget.message.clicked) {
        borderColour = Colors.yellow;
      }
    }
    // Now we check if it's maybe a data message with an image!
    if (isImage) {
      if (!widget.message.clicked) {
        borderColour = Colors.red;
      }
    }
    return borderColour;
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  Widget getMessageContent() {
    // We show the normal body, unless it's clicked. Than we show the extra info
    if (widget.message.clicked) {
      // If it's clicked we show the extra text message or the image!
      if (isImage) {
        if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
          return Column(
              children: [
                broImage!,
                Linkify(
                    onOpen: _onOpen,
                    text: widget.message.textMessage!,
                    linkStyle: TextStyle(color: Color(0xffD3D3D3), fontSize: 18),
                    style: simpleTextStyle()
                )
              ]
          );
        } else {
          return broImage!;
        }
      } else {
        return Linkify(
            onOpen: _onOpen,
            text: widget.message.textMessage!,
            linkStyle: TextStyle(color: Color(0xffD3D3D3), fontSize: 18),
            style: simpleTextStyle()
        );
      }
    } else {
      return Text(
          widget.message.body,
          style: simpleTextStyle()
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.message.isInformation()
        ? Row(
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
          )
        ])
        : Container(
        child: new Material(
          child: Column(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              margin: EdgeInsets.only(top: 12),
              width: MediaQuery.of(context).size.width,
              alignment: widget.myMessage
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              child: new InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(42),
                ),
                onTap: () {
                  selectMessage(context);
                },
                onLongPress: () {
                  if (isImage && widget.message.clicked) {
                    _showMessageDetailPopupMenu();
                  }
                },
                onTapDown: _storePosition,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                      child: getMessageContent()
                  ),
                ),
              ),
            ),
            Container(
              child: Align(
                alignment: widget.myMessage
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: DateFormat('HH:mm')
                              .format(widget.message.getTimeStamp()),
                          style:
                          TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        widget.myMessage
                            ? widget.message.isRead != 2
                            ? WidgetSpan(
                            child: Icon(Icons.done_all,
                                color: widget.message.hasBeenRead()
                                    ? Colors.blue
                                    : Colors.white54,
                                size: 18))
                            : WidgetSpan(
                            child: Icon(Icons.done,
                                color: Colors.white54, size: 18))
                            : WidgetSpan(child: Container()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
          color: Colors.transparent,
        ));
  }

  void _showMessageDetailPopupMenu() {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
        context: context,
        items: [
          BroMessageDetailPopup(
              key: UniqueKey()
          )
        ],
        position: RelativeRect.fromRect(_tapPosition & const Size(40, 40),
            Offset.zero & overlay.size))
        .then((int? delta) {
      print("pressed? delta: $delta");
      if (delta == 1) {
        // Save the image!
        saveImageToGallery();
      }
      return;
    });
  }

  Future<bool> requestPermissions() async {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      return await Gal.requestAccess();
    } else {
      return true;
    }
  }

  Future<void> saveImageToGallery() async {
    try {
      bool access = await requestPermissions();
      if (!access) {
        showToastMessage("No access to gallery");
        return;
      }
      Uint8List decoded = base64.decode(widget.message.data!);
      final albumName = "Brocast";
      await Gal.putImageBytes(decoded, album: albumName);

      showToastMessage("Image saved");
    } catch (e) {
      showToastMessage("Failed to save image: $e");
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

}

class BroMessageDetailPopup extends PopupMenuEntry<int> {

  BroMessageDetailPopup(
      {required Key key})
      : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  BroMessageDetailPopupState createState() => BroMessageDetailPopupState();

  @override
  double get height => 1;
}

class BroMessageDetailPopupState extends State<BroMessageDetailPopup> {
  @override
  Widget build(BuildContext context) {
    return getPopupItems(context);
  }
}

void buttonMessage(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

Widget getPopupItems(BuildContext context) {
  return Column(children: [
    Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonMessage(context);
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: Size(double.infinity, 0), // Make the button take full width
          ),
          child: Text(
            'Save image to gallery',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    )
  ]);
}
