import 'package:brocast/constants/api_path.dart';
import 'package:brocast/objects/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketServices {

  var messaging;
  IO.Socket socket;

  createSockConnection(int broId, int brosBroId, var messaging) {
    this.messaging = messaging;
    String namespace = "sock/message";
    String socketUrl = baseUrl + namespace;
    print(socketUrl);
    this.socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    this.socket.onConnect((_) {
      print('connect');
      socket.emit('message_event', 'Connected, ms server!');
      joinRoom(broId, brosBroId);
    });

    this.socket.onDisconnect((_) {
      print('disconnect');
      socket.emit('message_event', 'sorry ms server, disconnected!');
    });

    this.socket.on('message_event', (data) => print(data));
    this.socket.on('message_event_send', (data) => messageReceived(data));

    this.socket.open();
  }

  closeSockConnection() {
    if (this.socket.connected) {
      this.socket.close();
    }
  }

  joinRoom(int broId, int brosBroId) {
    print("creating room!");
    if (this.socket.connected) {
      print("socket connected");
      this.socket.emit("join",
        {
          "bro_id": broId,
          "bros_bro_id": brosBroId
        },
      );
      print("DONE!");
    }
  }

  sendMessageSocket(int broId, int brosBroId, String message) {
    if (this.socket.connected) {
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
    Message mes = new Message(data["id"], data["bro_bros_id"], data["sender_id"], data["recipient_id"], data["body"], data["timestamp"]);
    messaging.updateMessages(mes);
  }
}