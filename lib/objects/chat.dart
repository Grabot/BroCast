import 'dart:ui';

abstract class Chat {

  late int id;
  late DateTime lastActivity; // TODO: @Skools turn into String?
  late String roomName;
  late String chatName;
  late String chatDescription; // TODO: @Skools check that it is never null and always emptystring if there is no description
  late String alias; // TODO: @Skools check that it is never null and always emptystring if there is no alias
  late String chatColor;
  late int unreadMessages;
  late int blocked;
  late int mute;
  late int broup;

  Chat();

  String getBroNameOrAlias();
  Color getColor();

  bool isBlocked();
  setBlocked(bool blocked);
  bool isMuted();
  setMuted(bool muted);
  bool isBroup();
  setBroup(bool broup);

  Map<String, dynamic> toDbMap();
  Chat.fromDbMap(Map<String, dynamic> map);
}