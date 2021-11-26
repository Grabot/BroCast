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
      'autoConnect': false,
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

  void checkConnection() {
    if (!isConnected()) {
      startSockConnection();
    }
  }

  void joinRoomSolo(int broId) {
    if (!joinedSoloRoom) {
      // After you have logged in you want to remain in the bro's solo room.
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
      this.socket.on('message_event_chat_changed', (data) {
        chatChanged(data);
      });
      this.socket.on('message_event_send_solo', (data) {
        // TODO: @Skools do we still do a message_event_send_solo?
        print(data);
      });
    }
  }

  chatChanged(data) {
    print("chat changed :)");
    BroBros broBros = getBroBros(data);
    broList.updateChat(broBros);
    storage.updateChat(broBros).then((chat) {
      notifyListeners();
    });
  }

  void broAddedYou(data) {
    BroBros broBros = getBroBros(data);
    broList.addBro(broBros);
    storage.addChat(broBros).then((value) {
      notifyListeners();
    });
  }

  BroBros getBroBros(data) {
    return BroBros(
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
  }

  void leaveRoomSolo(int broId) {
    if (!joinedSoloRoom) {
      print("left the room");
      joinedSoloRoom = false;
      this.socket.emit(
        "leave_solo",
        {
          "bro_id": broId
        },
      );
      this.socket.off('message_event_bro_added_you');
      this.socket.off('message_event_send_solo');
    }
  }
}
