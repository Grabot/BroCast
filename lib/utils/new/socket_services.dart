import 'package:brocast/constants/base_url.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import 'package:brocast/views/chat_view/bro_messaging/bro_messaging_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../objects/message.dart';
import '../../objects/broup.dart';
import '../../objects/me.dart';
import 'storage.dart';
import 'settings.dart';

class SocketServices extends ChangeNotifier {
  late io.Socket socket;

  bool joinedSoloRoom = false;

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
  }

  startSockConnection() {
    String socketUrl = baseUrl_v1_0;
    socket = io.io(socketUrl, <String, dynamic>{
      'autoConnect': false,
      'path': "/socket.io",
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      socket.emit('message_event', 'Connected!');
    });

    socket.onDisconnect((_) {
      socket.emit('message_event', 'Disconnected!');
    });

    socket.on('message_event', (data) {
      print(data);
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
    // First leave the rooms before joining them
    // This is to prevent multiple joins
    leaveSocketsSolo();
    joinSocketsSolo();
  }

  chatChanged(data) async {
    print("chat changed $data");
    int broupId = data["broup_id"];
    Me? me = Settings().getMe();
    if (me != null) {
      Broup broup = me.bros.firstWhere((element) => element.broupId == broupId);
      if (data.containsKey("new_broup_colour")) {
        broup.setBroupColor(data["new_broup_colour"]);
      }
      if (data.containsKey("new_broup_description")) {
        broup.setBroupDescription(data["new_broup_description"]);
      }
      if (data.containsKey("new_broup_name")) {
        broup.setBroupName(data["new_broup_name"]);
      }
      Storage().updateBroup(broup);
      notifyListeners();
    }
  }

  chatAdded(data) async {
    var broup = data["broup"];
    Me? me = Settings().getMe();
    if (me != null) {
      // Add the broup. It's not possible that it already exists
      // so we don't account for that.
      Broup newBroup = Broup.fromJson(broup);
      Storage().addBroup(newBroup);
      me.bros.add(newBroup);
      joinRoomBroup(newBroup.getBroupId());
    }
    BroHomeChangeNotifier().notify();
  }

  messageReceived(data) async {
    print("message received $data");
    Message message = Message.fromJson(data);
    Storage storage = Storage();
    storage.addMessage(message);
    int broupId = message.broupId;
    Me? me = Settings().getMe();
    if (me != null) {
      Broup broup = me.bros.firstWhere((element) => element.broupId == broupId);
      broup.updateMessages(message);
      storage.updateBroup(broup);
      notifyListeners();
    }
  }

  messageRead(data) async {
    print("message read $data");
    int broupId = data["broup_id"];
    String timestamp = data["timestamp"];
    Me? me = Settings().getMe();
    if (me != null) {
      Broup broup = me.bros.firstWhere((element) => element.broupId == broupId);
      broup.updateLastReadMessages(timestamp);
      Storage().updateBroup(broup);
      notifyListeners();
    }
  }

  void joinRoomBroup(int broupId) {
    this.socket.emit(
      "join_broup",
      {
        "broup_id": broupId,
      },
    );
    leaveSocketsBroup();
    joinSocketsBroup();
  }

  joinSocketsSolo() {
    this.socket.on('chat_changed', (data) {
      chatChanged(data);
    });
    this.socket.on('chat_added', (data) {
      chatAdded(data);
    });
    // these messages will be send in the broup rooms,
    // but we need to listen to it here
    this.socket.on('message_received', (data) {
      messageReceived(data);
    });
    this.socket.on('message_read', (data) {
      messageRead(data);
    });
  }

  joinSocketsBroup() {
  }

  leaveSocketsSolo() {
    this.socket.off('chat_changed');
    this.socket.off('chat_added');
    this.socket.off('message_received');
    this.socket.off('message_read');
  }

  leaveSocketsBroup() {
  }

  void leaveRoomSolo(int broId) {
    joinedSoloRoom = false;
    this.socket.emit(
      "leave_solo",
      {"bro_id": broId},
    );
    leaveSocketsSolo();
  }

  leaveRoomBroup(int broupId) {
    this.socket.emit(
      "leave_broup",
      {"broup_id": broupId},
    );
  }
}
