import 'package:brocast/constants/api_path.dart';
import 'package:brocast/objects/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketServices {

  static SocketServices _instance = new SocketServices._internal();
  static get instance => _instance;
  IO.Socket socket;

  var messaging;

  SocketServices._internal( ) {
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
    socket.on('message_event_send', (data) => messageReceived(data));
    socket.on('message_event_read', (data) => messageRead(data));
    socket.open();
  }

  setMessaging(var messaging) {
    this.messaging = messaging;
  }

  listenForProfileChange(var profilePage) {
    this.socket.on('message_event_bromotion_change', (data) {
      print("the bromotion has changed to $data");
      if (data == "bromotion change successful") {
        profilePage.onChangeBromotionSuccess();
      } else if (data == "broName bromotion combination taken") {
        profilePage.onChangeBromotionFailedExists();
      } else {
        profilePage.onChangeBromotionFailedUnknown();
      }
    });
    this.socket.on('message_event_password_change', (data) {
      print("the password has changed to $data");
      if (data == "password change successful") {
        profilePage.onChangePasswordSuccess();
      } else {
        profilePage.onChangePasswordFailed();
      }
    });
  }

  stopListeningForProfileChange() {
    this.socket.off('message_event_bromotion_change', (data) => print(data));
    this.socket.off('message_event_password_change', (data) => print(data));
  }

  changeBromotion(String token, String bromotion) {
    if (this.socket.connected) {
      this.socket.emit("bromotion_change",
          {
            "token": token,
            "bromotion": bromotion
          }
      );
    }
  }

  changePassword(String token, String password) {
    if (this.socket.connected) {
      this.socket.emit("password_change",
          {
            "token": token,
            "password": password
          }
      );
    }
  }

  isConnected() {
    if (this.socket == null) {
      return false;
    }
    return this.socket.connected;
  }

  closeSockConnection() {
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

  sendMessageSocket(int broId, int brosBroId, String message, String textMessage) {
    if (this.socket.connected) {
      this.socket.emit("message",
        {
          "bro_id": broId,
          "bros_bro_id": brosBroId,
          "message": message,
          "text_message": textMessage
        },
      );
    }
  }

  messageReceived(var data) {
    Message mes = new Message(data["id"], data["bro_bros_id"], data["sender_id"], data["recipient_id"], data["body"], data["text_message"], data["timestamp"]);
    this.messaging.updateMessages(mes);
  }

  messageReadUpdate(int broId, int brosBroId) {
    if (this.socket.connected) {
      this.socket.emit("message_read",
        {
          "bro_id": broId,
          "bros_bro_id": brosBroId
        },
      );
    }
  }

  messageRead(var data) {
    // This will set all messages to read to anyone receiving the message read update while having the chat open
    this.messaging.updateRead();
  }
}