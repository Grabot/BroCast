import '../../../objects/broup.dart';

class ParticipantItem {
  late bool selected;
  late Broup broup;

  ParticipantItem(bool selected, Broup broup) {
    this.selected = selected;
    this.broup = broup;
  }

  getBroup() {
    return this.broup;
  }

  isSelected() {
    return this.selected;
  }

  setSelected(bool selected) {
    this.selected = selected;
  }
}
