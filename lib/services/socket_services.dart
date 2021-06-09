import 'package:brocast/constants/base_url.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketServices {
  static SocketServices _instance = new SocketServices._internal();

  static get instance => _instance;
  IO.Socket socket;

  SocketServices._internal() {
    startSockConnection();
  }

  startSockConnection() {
    String namespace = "sock";
    String socketUrl = baseUrl + namespace;
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      socket.emit('message_event', 'Connected, ms server!');
    });

    socket.onDisconnect((_) {
      socket.emit('message_event', 'sorry ms server, disconnected!');
    });

    socket.on('message_event', (data) => print(data));

    socket.open();
  }

  closeSockConnection() {
    print("it closed the socket again, dammit!");
    if (this.socket.connected) {
      this.socket.close();
    }
  }

}
