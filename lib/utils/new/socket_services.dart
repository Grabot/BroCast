import 'package:brocast/constants/base_url.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketServices extends ChangeNotifier {
  late IO.Socket socket;

  bool joinedSoloRoom = false;

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
  }

  startSockConnection() {
    String namespace = "/sock";
    String socketUrl = baseUrl_v1_0 + namespace;
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

    socket.on('message_event', (data) {
      // print(data);
    });

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
    // After you have logged in you want to remain in the bro's solo room.
    joinedSoloRoom = true;
    this.socket.emit(
      "join_solo",
      {
        "bro_id": broId,
      },
    );
    this.socket.off('message_event_chat_changed');
    joinSockets();
  }

  joinSockets() {
    this.socket.on('message_event_chat_changed', (data) {
      chatChanged(data);
    });
  }

  chatChanged(data) async {
    print("chat changed");
  }

  void leaveRoomSolo(int broId) {
    joinedSoloRoom = false;
    this.socket.emit(
      "leave_solo",
      {"bro_id": broId},
    );
    this.socket.off('message_event_chat_changed');
  }
}
