import 'dart:io';

import "package:flutter/material.dart";
import 'dart:math' as math;

class ImageViewer extends StatefulWidget {
  final File image;

  ImageViewer({
    required Key key,
    required this.image
  }) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  int rotationAngle = 0;
  double scaleFactor = 1.0;
  Offset? firstTapPosition;
  Offset? secondTapPosition;
  Offset? currentPosition;
  bool isTracking = false;

  void rotateLeft() {
    setState(() {
      rotationAngle -= 90;
    });
  }

  void rotateRight() {
    setState(() {
      rotationAngle += 90;
    });
  }

  void handleTapDown(TapDownDetails details) {
    if (!isTracking) {
      setState(() {
        if (firstTapPosition == null) {
          firstTapPosition = details.localPosition;
        } else {
          secondTapPosition = details.localPosition;
          isTracking = true;
        }
      });
    }
  }

  void handleTapUp(TapUpDetails details) {
    if (!isTracking) {
      setState(() {
      });
    }
  }

  double currentScaleMovement = 0.0;
  void handlePointerMove(PointerMoveEvent details) {
    if (isTracking) {
      setState(() {
        currentPosition = details.localPosition;
        double verticalDistance = (currentPosition!.dy - firstTapPosition!.dy);
        currentScaleMovement = verticalDistance / 100.0;
      });
    }
  }

  void handlePointerUp(PointerUpEvent details) {
    if (isTracking) {
      setState(() {
        scaleFactor = scaleFactor + currentScaleMovement;
        currentScaleMovement = 0.0;
        isTracking = false;
        firstTapPosition = null;
        secondTapPosition = null;
        currentPosition = null;
      });
    }
  }

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
                  "Image Viewer",
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
              child: Listener(
                onPointerMove: handlePointerMove,
                onPointerUp: handlePointerUp,
                child: GestureDetector(
                  onTapDown: handleTapDown,
                  onTapUp: handleTapUp,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.00001,
                      maxScale: 9999999,
                      scaleEnabled: true,
                      boundaryMargin: EdgeInsets.all(double.infinity),
                      child: Container(
                        child: Transform.rotate(
                          angle: rotationAngle * (math.pi / 180),
                          child: Transform.scale(
                            scale: (scaleFactor + currentScaleMovement),
                            child: Image.file(widget.image),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 30,
                    icon: Icon(Icons.rotate_left, color: Colors.white),
                    onPressed: rotateLeft,
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 30,
                    icon: Icon(Icons.rotate_right, color: Colors.white),
                    onPressed: rotateRight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
