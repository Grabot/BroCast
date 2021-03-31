import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket socket;

  createSocketConnection() {
    String socketUrl = "http://10.0.2.2:5000/test";
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    // this.socket.on("connect", (_) => print('Connected'));
    this.socket.onConnect((_) {
      print('connect');
      socket.emit('my_event', 'Connected, mr server!');
    });
    this.socket.on("disconnect", (_) => print('Disconnected'));
  }

  // Send a Message to the server
  sendMessage(String message) {
    socket.emit("message",
      {
        "id": socket.id,
        "message": message, // Message to be sent
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  sendTestNamespaceTest() {
    socket.on('event', (data) => print(data));
  }
}