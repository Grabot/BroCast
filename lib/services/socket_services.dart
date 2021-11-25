import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketServices extends ChangeNotifier {

  late IO.Socket socket;
  late Storage storage;
  late BroList broList;

  bool joinedSoloRoom = false;

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    storage = Storage();
    broList = BroList();
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
  }

  startSockConnection() {
    print("starting the socket connection");
    String namespace = "sock";
    String socketUrl = baseUrl + namespace;
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      socket.emit('message_event', 'Connected!');
    });

    socket.onDisconnect((_) {
      socket.emit('message_event', 'Disconnected!');
    });

    socket.on('message_event', (data) => print(data));

    socket.open();
  }

  bool isConnected() {
    return socket.connected;
  }

  void joinRoomSolo(int broId) {
    if (!joinedSoloRoom) {
      print("joined the room");
      joinedSoloRoom = true;
      this.socket.emit(
        "join_solo",
        {
          "bro_id": broId,
        },
      );
      this.socket.on('message_event_bro_added_you', (data) {
        broAddedYou(data);
      });
    }
  }

  void broAddedYou(data) {
    print("going to add a bro!");
    BroBros broBros = new BroBros(
        data["bros_bro_id"],
        data["chat_name"],
        data["chat_description"],
        data["alias"],
        data["chat_colour"],
        data["unread_messages"],
        data["last_time_activity"],
        data["room_name"],
        data["blocked"] ? 1 : 0,
        data["mute"] ? 1 : 0,
        0
    );
    broList.addBro(broBros);
    storage.addChat(broBros).then((value) {
      print("bro adding DONE");
      onChange();
    });
  }

  void leaveRoomSolo(int broId) {
    if (!joinedSoloRoom) {
      joinedSoloRoom = false;
      this.socket.emit(
        "leave_solo",
        {
          "bro_id": broId
        },
      );
    }
  }

  void onChange() {
    notifyListeners();
  }
}
