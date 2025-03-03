import 'package:flutter/foundation.dart';


class CropController {
  late CropControllerDelegate _delegate;

  set delegate(CropControllerDelegate value) => _delegate = value;
  void crop() => _delegate.onCrop();
  void reset() => _delegate.onReset();
  set image(Uint8List value) => _delegate.onImageChanged(value);

}

class CropControllerDelegate {
  late Function onCrop;
  late Function onReset;
  late ValueChanged<Uint8List> onImageChanged;
}
