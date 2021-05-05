import 'package:brocast/constants/api_path.dart';
import 'package:brocast/objects/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
    this.socket.on('message_event_read', (data) => messageRead(data));
    this.socket.open();
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
    this.messaging.updateMessages(mes);
  }

  messageReadUpdate(int broId, int brosBroId) {
    print("check socket message read");
    if (this.socket.connected) {
      print("socket is connected message read");
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