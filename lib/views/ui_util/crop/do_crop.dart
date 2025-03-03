import 'dart:typed_data';
import 'package:image/image.dart' as image;


Uint8List doCrop(List<dynamic> cropData) {
  final originalImage = cropData[0] as image.Image;
  final rect = cropData[1] as List;
  return Uint8List.fromList(
    image.encodePng(
      image.copyCrop(
        originalImage,
        x: rect[0].toInt(),
        y: rect[1].toInt(),
        width: rect[2].toInt(),
        height: rect[3].toInt(),
      ),
    ),
  );
}
