
import '../../../../../objects/broup.dart';

class BroupAddBro {
  late bool selected;
  late bool alreadyInBroup;
  late Broup broBros;

  BroupAddBro(bool selected, bool alreadyInBroup, Broup broBros) {
    this.selected = selected;
    this.alreadyInBroup = alreadyInBroup;
    this.broBros = broBros;
  }

  getBroBros() {
    return this.broBros;
  }

  isAlreadyInBroup() {
    return this.alreadyInBroup;
  }

  setAlreadyInBroup(bool alreadyInBroup) {
    this.alreadyInBroup = alreadyInBroup;
  }

  isSelected() {
    return this.selected;
  }

  setSelected(bool selected) {
    this.selected = selected;
  }
}
