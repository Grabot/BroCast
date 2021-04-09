import 'package:brocast/constants/api_path.dart';
import 'package:brocast/objects/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';

class SocketServices {

  var messaging;
  IO.Socket socket;

  startSockConnection() {
    String namespace = "sock";
    String socketUrl = baseUrl + namespace;
    print(socketUrl);
    this.socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    this.socket.onConnect((_) {
      print('connect');
      socket.emit('message_event', 'Connected, ms server!');
    });

    this.socket.onDisconnect((_) {
      print('disconnect');
      socket.emit('message_event', 'sorry ms server, disconnected!');
    });

    this.socket.on('message_event', (data) => print(data));
    this.socket.on('message_event_send', (data) => messageReceived(data));
    this.socket.open();
  }

  setMessaging(var messaging) {
    this.messaging = messaging;
  }

  isConnected() {
    if (this.socket == null) {
      return false;
    }
    return this.socket.connected;
  }

  closeSockConnection() {
    print("closing socket connection was called");
    if (this.socket.connected) {
      this.socket.close();
    }
  }

  joinRoom(int broId, int brosBroId) {
    if (this.socket.connected) {
      this.socket.emit("join",
        {
          "bro_id": broId,
          "bros_bro_id": brosBroId
        },
      );
    }
  }

  leaveRoom(int broId, int brosBroId) {
    if (this.socket.connected) {
      this.socket.emit("leave",
        {
          "bro_id": broId,
          "bros_bro_id": brosBroId
        },
      );
    }
  }

  sendMessageSocket(int broId, int brosBroId, String message) {
    print("check socket");
    if (this.socket.connected) {
      print("socket is connected");
      this.socket.emit("message",
        {
          "bro_id": broId,
          "bros_bro_id": brosBroId,
          "message": message
        },
      );
    }
  }

  messageReceived(var data) {
    sleep(Duration(seconds:5));
    Message mes = new Message(data["id"], data["bro_bros_id"], data["sender_id"], data["recipient_id"], data["body"], data["timestamp"]);
    this.messaging.updateMessages(mes);
  }
}