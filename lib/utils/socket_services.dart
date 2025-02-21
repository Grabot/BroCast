import 'package:brocast/constants/base_url.dart';
import 'package:brocast/services/auth/auth_service_social.dart';
import 'package:brocast/utils/socket_services_util.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import 'package:brocast/views/chat_view/messaging_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../objects/bro.dart';
import '../objects/message.dart';
import '../objects/broup.dart';
import '../objects/me.dart';
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
      Broup broup = me.broups.firstWhere((element) => element.broupId == broupId);
      if (data.containsKey("new_broup_colour")) {
        broup.setBroupColor(data["new_broup_colour"]);
      }
      if (data.containsKey("new_broup_description")) {
        broup.setBroupDescription(data["new_broup_description"]);
      }
      if (data.containsKey("new_broup_name")) {
        broup.setBroupName(data["new_broup_name"]);
      }
      if (data.containsKey("new_member_id")) {
        int newMemberId = data["new_member_id"];
        broup.addBroId(newMemberId);
        broup.newMembersBroup();
        if (Settings().getMe()!.getId() == newMemberId) {
          broup.removed = false;
        }
      }
      if (data.containsKey("new_admin_id")) {
        print("new admin! ${data["new_admin_id"]}");
        int newAdminId = data["new_admin_id"];
        broup.addAdminId(newAdminId);
      }
      if (data.containsKey("dismissed_admin_id")) {
        int dismissedMemberId = data["dismissed_admin_id"];
        broup.removeAdminId(dismissedMemberId);
      }
      if (data.containsKey("remove_bro_id")) {
        int removedBroId = data["remove_bro_id"];
        broup.removeBro(removedBroId);
        // It's possible that you have been removed from the broup
        if (Settings().getMe()!.getId() == removedBroId) {
          broup.removed = true;
        }
      }
      if (data.containsKey("broup_updated")) {
        // probably True, we should update broup
        bool broupUpdated = data["broup_updated"];
        broup.setUpdateBroup(broupUpdated);
      }
      Storage().updateBroup(broup);
      notifyListeners();
    }
  }

  chatAdded(data) async {
    print("chat added $data");
    var broup = data["broup"];
    Me? me = Settings().getMe();
    if (me != null) {
      // Add the broup. It's not possible that it already exists
      // so we don't account for that.
      Broup newBroup = Broup.fromJson(broup);
      Storage().addBroup(newBroup);
      me.addBroup(newBroup);

      if (newBroup.private) {
        for (int broId in newBroup.broIds) {
          if (broId != me.getId()) {
            // For private chats we want to retrieve the bro object.
            AuthServiceSocial().retrieveBro(broId).then((bro) {
              if (bro != null) {
                newBroup.addBro(bro);
                Storage().addBro(bro);
                notifyListeners();
              }
            });
            break;
          }
        }
      }
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
      Broup broup = me.broups.firstWhere((element) => element.broupId == broupId);
      if (!broup.removed) {
        broup.updateMessages(message);
        storage.updateBroup(broup);
        notifyListeners();
      }
    }
  }

  messageRead(data) async {
    print("message read $data");
    int broupId = data["broup_id"];
    String timestamp = data["timestamp"];
    Me? me = Settings().getMe();
    if (me != null) {
      Broup broup = me.broups.firstWhere((element) => element.broupId == broupId);
      broup.updateLastReadMessages(timestamp);
      Storage().updateBroup(broup);
      notifyListeners();
    }
  }

  broUpdated(data) async {
    print("bro updated $data");
    Me? me = Settings().getMe();
    if (me != null) {
      if (data.containsKey("bromotion")) {
        String newBromotion = data["bromotion"];
        int broId = data["bro_id"];
        broUpdatedBromotion(me, broId, newBromotion);
      }
      if (data.containsKey("broname")) {
        String newBroname = data["broname"];
        int broId = data["bro_id"];
        broUpdatedBroname(me, broId, newBroname);
      }
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
    this.socket.on('bro_update', (data) {
      broUpdated(data);
    });
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
