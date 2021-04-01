import 'package:brocast/constants/api_path.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket socket;

  createConnection(int broId, int brosBroId) {
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
    this.socket.on('message_sent_event', (data) => print(data));

    this.socket.open();
  }

  closeConnection() {
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
  sendMessage(int broId, int brosBroId, String message) {
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

}