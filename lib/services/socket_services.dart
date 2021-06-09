import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'notification_service.dart';

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

  void updateBroChatDetails(String token, int broId, String description) {
    if (this.socket.connected) {
      this.socket.emit("message_event_change_chat_details",
          {"token": token, "bros_bro_id": broId, "description": description});
    }
  }

  void updateBroChatColour(String token, int broId, String colour) {
    if (this.socket.connected) {
      this.socket.emit("message_event_change_chat_colour",
          {"token": token, "bros_bro_id": broId, "colour": colour});
    }
  }

  listenForBroChatDetails(var broChatDetails) {
    this.socket.on('message_event_change_chat_details_success', (data) {
      broChatDetails.chatDetailUpdateSuccess();
    });
    this.socket.on('message_event_change_chat_details_failed', (data) {
      broChatDetails.chatDetailUpdateFailed();
    });
    this.socket.on('message_event_change_chat_colour_success', (data) {
      broChatDetails.chatColourUpdateSuccess();
    });
    this.socket.on('message_event_change_chat_colour_failed', (data) {
      broChatDetails.chatColourUpdateFailed();
    });
  }

  stopListeningForBroChatDetails() {
    this.socket.off(
        'message_event_change_chat_details_success', (data) => print(data));
    this
        .socket
        .off('message_event_change_chat_details_failed', (data) => print(data));
  }

  isConnected() {
    if (this.socket == null) {
      return false;
    }
    return this.socket.connected;
  }

  closeSockConnection() {
    print("it closed the socket again, dammit!");
    if (this.socket.connected) {
      this.socket.close();
    }
  }

}
