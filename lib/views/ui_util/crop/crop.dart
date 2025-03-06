import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;

import 'controller.dart';
import 'do_crop.dart';

const dotTotalSize = 50.0;

typedef CroppingAreaBuilder = Rect Function(Rect imageRect);

enum EdgeAlignment {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

enum CropStatus { loading, ready, cropping }

class Crop extends StatelessWidget {

  final Uint8List image;
  final ValueChanged<Uint8List> onCropped;
  final bool hexCrop;

  final CropController? controller;

  final ValueChanged<CropStatus>? onStatusChanged;
  final ValueChanged<Uint8List>? onResize;

  const Crop({
    super.key,
    required this.image,
    required this.onCropped,
    required this.hexCrop,
    this.controller,
    this.onStatusChanged,
    this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final newData = MediaQuery.of(context).copyWith(
          size: constraints.biggest,
        );
        return MediaQuery(
          data: newData,
          child: _CropEditor(
            image: image,
            onCropped: onCropped,
            hexCrop: hexCrop,
            controller: controller,
            onStatusChanged: onStatusChanged,
            onResize: onResize,
          ),
        );
      },
    );
  }
}

class _CropEditor extends StatefulWidget {
  final Uint8List image;
  final ValueChanged<Uint8List> onCropped;
  final CropController? controller;
  final bool hexCrop;
  final ValueChanged<CropStatus>? onStatusChanged;
  final ValueChanged<Uint8List>? onResize;

  const _CropEditor({
    required this.image,
    required this.onCropped,
    required this.hexCrop,
    this.controller,
    this.onStatusChanged,
    this.onResize,
  });

  @override
  _CropEditorState createState() => _CropEditorState();
}

class _CropEditorState extends State<_CropEditor> {
  late CropController _cropController;
  late Rect _rect;
  image.Image? _targetImage;
  late Rect _imageRect;

  bool cropping = false;

  bool _isFitVertically = false;
  Future<image.Image?>? _lastComputed;

  bool imageLoaded = false;
  int maxSize = 1024;

  _Calculator get calculator => _isFitVertically
      ? const _VerticalCalculator()
      : const _HorizontalCalculator();

  set rect(Rect newRect) {
    setState(() {
      _rect = newRect;
    });
  }

  // for zooming
  int _pointerNum = 0;

  @override
  void initState() {
    _cropController = widget.controller ?? CropController();
    _cropController.delegate = CropControllerDelegate()
      ..onCrop = _crop
      ..onReset = resetClipArea
      ..onImageChanged = _resetImage;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    imageLoaded = false;
    _resetCroppingArea(1.0);
    resetMobile(widget.image, false);
    print("did change dependencies");
    super.didChangeDependencies();
  }

  void _resetImage(Uint8List targetImage) async {
    // It's possible to load a new image before the previous one is loaded
    // So we need to wait for the previous one to be loaded
    while (imageLoaded == false) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    widget.onStatusChanged?.call(CropStatus.loading);
    print("reset image!");
    resetMobile(targetImage, true);
  }

  resizeImage(int width, int height, image.Image converted) {
    print("resize image!");
    if (width < height) {
      converted = image.copyResize(converted, height: maxSize);
    } else {
      converted = image.copyResize(converted, width: maxSize);
    }
    Uint8List data = image.encodePng(converted);
    widget.onResize?.call(data);
  }

  setImage(bool resetCrop, image.Image converted) {
    print("setting image");
    setState(() {
      _targetImage = converted;
    });
    if (resetCrop) {
      double imageRatio = _targetImage!.width / _targetImage!.height;
      _resetCroppingArea(imageRatio);
      _crop();
    }
    if (!cropping) {
      widget.onStatusChanged?.call(CropStatus.ready);
    }
    imageLoaded = true;
  }

  resetMobile(Uint8List targetImage, bool resetCrop) {
    print("reset mobile");
    final future = compute(_fromByteData, targetImage);
    _lastComputed = future;
    future.then((converted) {
      if (_lastComputed == future) {
        int width = converted.width;
        int height = converted.height;
        if (width > maxSize || height > maxSize) {
          // The image is too large, resize it too a more manageable size
          resizeImage(width, height, converted);
          // The resize will trigger an onImageChanged, so don't set image here.
        } else {
          setState(() {
            _targetImage = converted;
            _lastComputed = null;
          });
          if (resetCrop) {
            double imageRatio = _targetImage!.width / _targetImage!.height;
            _resetCroppingArea(imageRatio);
          }

          if (!cropping) {
            widget.onStatusChanged?.call(CropStatus.ready);
          }
          imageLoaded = true;
        }
      }
    });
  }

  void _resetCroppingArea(double imageRatio) {
    final screenSize = MediaQuery.of(context).size;

    _isFitVertically = imageRatio < screenSize.aspectRatio;

    _imageRect = calculator.imageRect(screenSize, imageRatio);

    _resizeWith();
  }

  void _resizeWith() {

    rect = calculator.initialCropRect(
      MediaQuery.of(context).size,
      _imageRect,
      1,
      1,
    );
  }

  resetClipArea() {
    _resetCroppingArea(1.0);
  }

  /// crop given image with given area.
  Future<void> _crop() async {
    print("going to crop");
    cropping = true;
    widget.onStatusChanged?.call(CropStatus.cropping);
    // Wait until _targetImage is not null
    while (imageLoaded == false) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    imageLoaded = false;

    final screenSizeRatio = calculator.screenSizeRatio(
      _targetImage!,
      MediaQuery.of(context).size,
    );

    List rectangle = [
      (_rect.left - _imageRect.left) * screenSizeRatio,
      (_rect.top - _imageRect.top) * screenSizeRatio,
      _rect.width * screenSizeRatio,
      _rect.height * screenSizeRatio
    ];

    cropMobile(rectangle);
  }

  cropMobile(List rectangle) {
    print("cropping mobile!");
    compute(
      doCrop,
      [
        _targetImage!,
        rectangle
      ],
    ).then((cropResult) {
      widget.onCropped(cropResult);
      widget.onStatusChanged?.call(CropStatus.ready);
      imageLoaded = true;
      cropping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerDown: (_) => _pointerNum++,
          onPointerUp: (_) => _pointerNum--,
          child: GestureDetector(
            // onScaleStart: widget.interactive ? _startScale : null,
            // onScaleUpdate: widget.interactive ? _updateScale : null,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    left: _imageRect.left,
                    top: _imageRect.top,
                    child: Image.memory(
                      widget.image,
                      width: _isFitVertically
                          ? null
                          : MediaQuery.of(context).size.width,
                      height: _isFitVertically
                          ? MediaQuery.of(context).size.height
                          : null,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: ClipPath(
            clipper: widget.hexCrop ? _CropAreaHexClipper(_rect) : _CropAreaCrestClipper(_rect),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withAlpha(100),
            ),
          ),
        ),
        Positioned(
          left: _rect.left,
          top: _rect.top,
          child: GestureDetector(
            onPanUpdate: (details) {
              rect = calculator.moveRect(
                _rect,
                details.delta.dx,
                details.delta.dy,
                _imageRect,
              );
            },
            onPanEnd: (details) {
              _crop();
            },
            child: Container(
              width: _rect.width,
              height: _rect.height,
              color: Colors.transparent,
            ),
          ),
        ),
        Positioned( // top left
          left: _rect.left - (dotTotalSize/4),
          top: _rect.top - (dotTotalSize/4),
          child: GestureDetector(
            onPanUpdate: (details) {
              rect = calculator.moveTopLeft(
                _rect,
                details.delta.dx,
                details.delta.dy,
                _imageRect,
                1.0,
              );
            },
            onPanEnd: (details) {
              _crop();
            },
            child: const DotControl(),
          ),
        ),
        Positioned( // top right
          left: _rect.right - (dotTotalSize / 4) * 3,
          top: _rect.top - (dotTotalSize / 4),
          child: GestureDetector(
            onPanUpdate: (details) {
              rect = calculator.moveTopRight(
                _rect,
                details.delta.dx,
                details.delta.dy,
                _imageRect,
                1.0,
              );
            },
            onPanEnd: (details) {
              _crop();
            },
            child: const DotControl(),
          ),
        ),
        Positioned( // bottom left
          left: _rect.left - (dotTotalSize / 4),
          top: _rect.bottom - (dotTotalSize / 4) * 3,
          child: GestureDetector(
            onPanUpdate: (details) {
              rect = calculator.moveBottomLeft(
                _rect,
                details.delta.dx,
                details.delta.dy,
                _imageRect,
                1.0,
              );
            },
            onPanEnd: (details) {
              _crop();
            },
            child: const DotControl(),
          ),
        ),
        Positioned( // bottom right
          left: _rect.right - (dotTotalSize / 4) * 3,
          top: _rect.bottom - (dotTotalSize / 4) * 3,
          child: GestureDetector(
            onPanUpdate: (details) {
              rect = calculator.moveBottomRight(
                _rect,
                details.delta.dx,
                details.delta.dy,
                _imageRect,
                1.0,
              );
            },
            onPanEnd: (details) {
              _crop();
            },
            child: const DotControl(),
          ),
        ),
      ],
    );
  }
}

class _CropAreaCrestClipper extends CustomClipper<Path> {
  _CropAreaCrestClipper(this.rect);

  final Rect rect;

  @override
  Path getClip(Size size) {

    final path = Path();
    double width = rect.width;
    double height = rect.height;

    // Determined these points with some trial and error.
    List point1 = [width/2 + rect.left, height/93.875 + rect.top];
    List point2 = [width/4.90441 + rect.left, height/8.94047 + rect.top];
    List point3 = [width/27.79166 + rect.left, height/11.734375 + rect.top];
    List point4 = [width/83.375 + rect.left, height/1.61853 + rect.top];
    List point5 = [width/5.05303 + rect.left, height/1.19586 + rect.top];
    List point6 = [width/2.41666 + rect.left, height/1.03159 + rect.top];
    List point7 = [(width/2)-2 + rect.left, height + rect.top];
    List point8 = [(width/2)+2 + rect.left, height + rect.top];
    List point9 = [width/1.70153 + rect.left, height/1.03159 + rect.top];
    List point10 = [width/1.24440 + rect.left, height/1.19586 + rect.top];
    List point11 = [width/1.010606 + rect.left, height/1.61853 + rect.top];
    List point12 = [width/1.035714 + rect.left, height/11.734375 + rect.top];
    List point13 = [width/1.253759 + rect.left, height/8.94047 + rect.top];

    path.moveTo(point1[0], point1[1]);
    path.lineTo(point2[0], point2[1]);
    path.lineTo(point3[0], point3[1]);
    path.lineTo(point4[0], point4[1]);
    path.lineTo(point5[0], point5[1]);
    path.lineTo(point6[0], point6[1]);
    path.lineTo(point7[0], point7[1]);
    path.lineTo(point8[0], point8[1]);
    path.lineTo(point9[0], point9[1]);
    path.lineTo(point10[0], point10[1]);
    path.lineTo(point11[0], point11[1]);
    path.lineTo(point12[0], point12[1]);
    path.lineTo(point13[0], point13[1]);
    path.close();

    return Path()
      ..addPath(path, Offset.zero)
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class _CropAreaHexClipper extends CustomClipper<Path> {
  _CropAreaHexClipper(this.rect);

  final Rect rect;

  @override
  Path getClip(Size size) {

    final path = Path();
    List point1 = getPointyHexCornerAvatar(rect, 0);
    List point2 = getPointyHexCornerAvatar(rect, 1);
    List point3 = getPointyHexCornerAvatar(rect, 2);
    List point4 = getPointyHexCornerAvatar(rect, 3);
    List point5 = getPointyHexCornerAvatar(rect, 4);
    List point6 = getPointyHexCornerAvatar(rect, 5);

    // 2,3 are the bottom 2 points and 5,6 are the top 2 points
    // We move those to the bottom and the top of the image
    point2[1] = rect.bottom;
    point3[1] = rect.bottom;
    point5[1] = rect.top;
    point6[1] = rect.top;

    path.moveTo(point1[0], point1[1]);
    path.lineTo(point2[0], point2[1]);
    path.lineTo(point3[0], point3[1]);
    path.lineTo(point4[0], point4[1]);
    path.lineTo(point5[0], point5[1]);
    path.lineTo(point6[0], point6[1]);
    path.close();

    return Path()
      ..addPath(path, Offset.zero)
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  List getPointyHexCornerAvatar(Rect rect, double i) {
    double angleDeg = 60 * i;

    double startX = rect.left;
    double startY = rect.top;
    double xSize = rect.width / 2;
    double ySize = rect.height / 2;

    double angleRad = pi/180 * angleDeg;
    double pointX = startX + (xSize * cos(angleRad)) + xSize;
    double pointY = startY + (ySize * sin(angleRad)) + ySize;
    return [pointX, pointY];
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Defalt dot widget placed on corners to control cropping area.
/// This Widget automaticall fits the appropriate size.
class DotControl extends StatelessWidget {
  const DotControl({
    super.key,
    this.color = Colors.white,
    this.padding = 8,
  });

  /// [Color] of this widget. [Colors.white] by default.
  final Color color;

  /// The size of transparent padding which exists to make dot easier to touch.
  /// Though total size of this widget cannot be changed,
  /// but visible size can be changed by setting this value.
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: dotTotalSize,
      height: dotTotalSize,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(dotTotalSize),
          child: Container(
            width: dotTotalSize - (padding * 2),
            height: dotTotalSize - (padding * 2),
            color: color,
          ),
        ),
      ),
    );
  }
}

// decode orientation awared Image.
image.Image _fromByteData(Uint8List data) {
  return image.decodeImage(data)!;
}

/// Calculation logics for various [Rect] data.
abstract class _Calculator {
  const _Calculator();

  /// calculates [Rect] of image to fit the screenSize.
  Rect imageRect(Size screenSize, double imageRatio);

  /// calculates [Rect] of initial cropping area.
  Rect initialCropRect(
      Size screenSize, Rect imageRect, double aspectRatio, double sizeRatio);

  /// calculates initial scale of image to cover _CropEditor
  double scaleToCover(Size screenSize, Rect imageRect);

  /// calculates ratio of [targetImage] and [screenSize]
  double screenSizeRatio(image.Image targetImage, Size screenSize);

  /// calculates [Rect] of the result of user moving the cropping area.
  Rect moveRect(Rect original, double deltaX, double deltaY, Rect imageRect) {
    if (original.left + deltaX < imageRect.left) {
      deltaX = (original.left - imageRect.left) * -1;
    }
    if (original.right + deltaX > imageRect.right) {
      deltaX = imageRect.right - original.right;
    }
    if (original.top + deltaY < imageRect.top) {
      deltaY = (original.top - imageRect.top) * -1;
    }
    if (original.bottom + deltaY > imageRect.bottom) {
      deltaY = imageRect.bottom - original.bottom;
    }
    return Rect.fromLTWH(
      original.left + deltaX,
      original.top + deltaY,
      original.width,
      original.height,
    );
  }

  /// calculates [Rect] of the result of user moving the top-left dot.
  Rect moveTopLeft(Rect original, double deltaX, double deltaY, Rect imageRect,
      double? aspectRatio) {
    final newLeft =
    max(imageRect.left, min(original.left + deltaX, original.right - 40));
    final newTop =
    min(max(original.top + deltaY, imageRect.top), original.bottom - 40);
    if (aspectRatio == null) {
      return Rect.fromLTRB(
        newLeft,
        newTop,
        original.right,
        original.bottom,
      );
    } else {
      if (deltaX.abs() > deltaY.abs()) {
        var newWidth = original.right - newLeft;
        var newHeight = newWidth / aspectRatio;
        if (original.bottom - newHeight < imageRect.top) {
          newHeight = original.bottom - imageRect.top;
          newWidth = newHeight * aspectRatio;
        }

        return Rect.fromLTRB(
          original.right - newWidth,
          original.bottom - newHeight,
          original.right,
          original.bottom,
        );
      } else {
        var newHeight = original.bottom - newTop;
        var newWidth = newHeight * aspectRatio;
        if (original.right - newWidth < imageRect.left) {
          newWidth = original.right - imageRect.left;
          newHeight = newWidth / aspectRatio;
        }
        return Rect.fromLTRB(
          original.right - newWidth,
          original.bottom - newHeight,
          original.right,
          original.bottom,
        );
      }
    }
  }

  Rect moveTopRight(Rect original, double deltaX, double deltaY, Rect imageRect,
      double? aspectRatio) {
    final newTop =
    min(max(original.top + deltaY, imageRect.top), original.bottom - 40);
    final newRight =
    max(min(original.right + deltaX, imageRect.right), original.left + 40);
    if (aspectRatio == null) {
      return Rect.fromLTRB(
        original.left,
        newTop,
        newRight,
        original.bottom,
      );
    } else {
      if (deltaX.abs() > deltaY.abs()) {
        var newWidth = newRight - original.left;
        var newHeight = newWidth / aspectRatio;
        if (original.bottom - newHeight < imageRect.top) {
          newHeight = original.bottom - imageRect.top;
          newWidth = newHeight * aspectRatio;
        }

        return Rect.fromLTWH(
          original.left,
          original.bottom - newHeight,
          newWidth,
          newHeight,
        );
      } else {
        var newHeight = original.bottom - newTop;
        var newWidth = newHeight * aspectRatio;
        if (original.left + newWidth > imageRect.right) {
          newWidth = imageRect.right - original.left;
          newHeight = newWidth / aspectRatio;
        }
        return Rect.fromLTRB(
          original.left,
          original.bottom - newHeight,
          original.left + newWidth,
          original.bottom,
        );
      }
    }
  }

  Rect moveBottomLeft(Rect original, double deltaX, double deltaY,
      Rect imageRect, double? aspectRatio) {
    final newLeft =
    max(imageRect.left, min(original.left + deltaX, original.right - 40));
    final newBottom =
    max(min(original.bottom + deltaY, imageRect.bottom), original.top + 40);

    if (aspectRatio == null) {
      return Rect.fromLTRB(
        newLeft,
        original.top,
        original.right,
        newBottom,
      );
    } else {
      if (deltaX.abs() > deltaY.abs()) {
        var newWidth = original.right - newLeft;
        var newHeight = newWidth / aspectRatio;
        if (original.top + newHeight > imageRect.bottom) {
          newHeight = imageRect.bottom - original.top;
          newWidth = newHeight * aspectRatio;
        }

        return Rect.fromLTRB(
          original.right - newWidth,
          original.top,
          original.right,
          original.top + newHeight,
        );
      } else {
        var newHeight = newBottom - original.top;
        var newWidth = newHeight * aspectRatio;
        if (original.right - newWidth < imageRect.left) {
          newWidth = original.right - imageRect.left;
          newHeight = newWidth / aspectRatio;
        }
        return Rect.fromLTRB(
          original.right - newWidth,
          original.top,
          original.right,
          original.top + newHeight,
        );
      }
    }
  }

  Rect moveBottomRight(Rect original, double deltaX, double deltaY,
      Rect imageRect, double? aspectRatio) {
    final newRight =
    min(imageRect.right, max(original.right + deltaX, original.left + 40));
    final newBottom =
    max(min(original.bottom + deltaY, imageRect.bottom), original.top + 40);
    if (aspectRatio == null) {
      return Rect.fromLTRB(
        original.left,
        original.top,
        newRight,
        newBottom,
      );
    } else {
      if (deltaX.abs() > deltaY.abs()) {
        var newWidth = newRight - original.left;
        var newHeight = newWidth / aspectRatio;
        if (original.top + newHeight > imageRect.bottom) {
          newHeight = imageRect.bottom - original.top;
          newWidth = newHeight * aspectRatio;
        }

        return Rect.fromLTWH(
          original.left,
          original.top,
          newWidth,
          newHeight,
        );
      } else {
        var newHeight = newBottom - original.top;
        var newWidth = newHeight * aspectRatio;
        if (original.left + newWidth > imageRect.right) {
          newWidth = imageRect.right - original.left;
          newHeight = newWidth / aspectRatio;
        }
        return Rect.fromLTWH(
          original.left,
          original.top,
          newWidth,
          newHeight,
        );
      }
    }
  }

  /// correct [Rect] not to exceed [Rect] of image.
  Rect correct(Rect rect, Rect imageRect) {
    return Rect.fromLTRB(
      max(rect.left, imageRect.left),
      max(rect.top, imageRect.top),
      min(rect.right, imageRect.right),
      min(rect.bottom, imageRect.bottom),
    );
  }
}

class _HorizontalCalculator extends _Calculator {
  const _HorizontalCalculator();

  @override
  Rect imageRect(Size screenSize, double imageRatio) {
    final imageScreenHeight = screenSize.width / imageRatio;
    final top = (screenSize.height - imageScreenHeight) / 2;
    final bottom = top + imageScreenHeight;
    return Rect.fromLTWH(0, top, screenSize.width, bottom - top);
  }

  @override
  Rect initialCropRect(
      Size screenSize, Rect imageRect, double aspectRatio, double sizeRatio) {
    final imageRatio = imageRect.width / imageRect.height;
    final imageScreenHeight = screenSize.width / imageRatio;

    final initialSize = imageRatio > aspectRatio
        ? Size((imageScreenHeight * aspectRatio) * sizeRatio,
        imageScreenHeight * sizeRatio)
        : Size(screenSize.width * sizeRatio,
        (screenSize.width / aspectRatio) * sizeRatio);

    return Rect.fromLTWH(
      (screenSize.width - initialSize.width) / 2,
      (screenSize.height - initialSize.height) / 2,
      initialSize.width,
      initialSize.height,
    );
  }

  @override
  double scaleToCover(Size screenSize, Rect imageRect) {
    return screenSize.height / imageRect.height;
  }

  @override
  double screenSizeRatio(image.Image targetImage, Size screenSize) {
    return targetImage.width / screenSize.width;
  }
}

class _VerticalCalculator extends _Calculator {
  const _VerticalCalculator();

  @override
  Rect imageRect(Size screenSize, double imageRatio) {
    final imageScreenWidth = screenSize.height * imageRatio;
    final left = (screenSize.width - imageScreenWidth) / 2;
    final right = left + imageScreenWidth;
    return Rect.fromLTWH(left, 0, right - left, screenSize.height);
  }

  @override
  Rect initialCropRect(
      Size screenSize, Rect imageRect, double aspectRatio, double sizeRatio) {
    final imageRatio = imageRect.width / imageRect.height;
    final imageScreenWidth = screenSize.height * imageRatio;

    final initialSize = imageRatio < aspectRatio
        ? Size(imageScreenWidth * sizeRatio,
        imageScreenWidth / aspectRatio * sizeRatio)
        : Size((screenSize.height * aspectRatio) * sizeRatio,
        screenSize.height * sizeRatio);

    return Rect.fromLTWH(
      (screenSize.width - initialSize.width) / 2,
      (screenSize.height - initialSize.height) / 2,
      initialSize.width,
      initialSize.height,
    );
  }

  @override
  double scaleToCover(Size screenSize, Rect imageRect) {
    return screenSize.width / imageRect.width;
  }

  @override
  double screenSizeRatio(image.Image targetImage, Size screenSize) {
    return targetImage.height / screenSize.height;
  }
}
