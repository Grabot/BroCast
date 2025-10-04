
enum DataType {
  image(0, "Image"),
  video(1, "Video"),
  audio(2, "Audio"),
  location(3, "Location"),
  liveLocation(4, "LiveLocation"),
  liveLocationStop(5, "LiveLocationStop"),
  gif(6, "Gif"),
  other(7, "other");

  const DataType(this.value, this.typeName);
  final int value;
  final String typeName;

  static DataType getByValue(int i){
    return DataType.values.firstWhere((x) => x.value == i);
  }
}
