
enum DataType {
  image(0, "Image"),
  video(1, "Video"),
  audio(2, "Audio"),
  location(3, "Location");

  const DataType(this.value, this.typeName);
  final int value;
  final String typeName;

  static DataType getByValue(int i){
    return DataType.values.firstWhere((x) => x.value == i);
  }
}

