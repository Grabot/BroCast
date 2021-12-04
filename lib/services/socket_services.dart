import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/bro_not_added.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/get_broup_bros.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketServices extends ChangeNotifier {

  late IO.Socket socket;
  late Storage storage;
  late BroList broList;

  bool joinedSoloRoom = false;

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
  }

  setStorageInstance(Storage storage) {
    this.storage = storage;
  }

  setBroListInstance(BroList broList) {
    this.broList = broList;
  }

  startSockConnection() {
    print("starting the socket connection");
    String namespace = "sock";
    String socketUrl = baseUrl + namespace;
    socket = IO.io(socketUrl, <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      socket.emit('message_event', 'Connected!');
    });

    socket.onDisconnect((_) {
      socket.emit('message_event', 'Disconnected!');
    });

    socket.on('message_event', (data) => print(data));

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
    if (!joinedSoloRoom) {
      // After you have logged in you want to remain in the bro's solo room.
      print("going to join room $broId");
      joinedSoloRoom = true;
      this.socket.emit(
        "join_solo",
        {
          "bro_id": broId,
        },
      );
      this.socket.on('message_event_bro_added_you', (data) {
        broAddedYou(data);
      });
      this.socket.on('message_event_chat_changed', (data) {
        chatChanged(data);
      });
      this.socket.on('message_event_added_to_broup', (data) {
        print("added to a broup!");
        broAddedYouToABroup(data);
      });
      this.socket.on('message_event_send_solo', (data) {
        // TODO: @Skools do we still do a message_event_send_solo?
        print(data);
      });
    }
  }

  broAddedYouToABroup(data) {
    print("added a broup, getting information!");
    Broup broup = getBroup(data);
    print("length of broupbros before: ${broup.getBroupBros()}");
    List<Bro> broupBros = [];
    // We assume this object is always filled an always in the participant list.
    broList.chatChangedCheckForAdded(broup.id, broup.getParticipants(), broup.getAdmins(), [], broupBros);
    broup.setBroupBros(broupBros);
    print("length of broupbros after: ${broup.getBroupBros()}");
    storage.selectChat(broup.id.toString(), broup.broup.toString()).then((value) {
      if (value == null) {
        storage.addChat(broup).then((value) {
          broList.addChat(broup);
          notifyListeners();
        });
      } else {
        storage.updateChat(broup).then((value) {
          broList.updateChat(broup);
          notifyListeners();
        });
      }
    });
  }

  updateBroups() {
    for (Chat broup in broList.getBros()) {
      if (broup.isBroup()) {
        print("updating broup ${broup.id}");
        List<Bro> broupBros = [];
        broup as Broup;
        broList.chatChangedCheckForAdded(broup.id, broup.getParticipants(), broup.getAdmins(), [], broupBros);
        broList.chatCheckForDBRemoved(broup.id, broup.getParticipants());
        broup.setBroupBros(broupBros);
      }
    }
  }

  chatChanged(data) async {
    if (data.containsKey("chat_name")) {
      print("chat has changed!");
      BroBros broBros = getBroBros(data);
      broList.updateChat(broBros);
      storage.updateChat(broBros).then((chat) {
        print("we have updated the chat");
        notifyListeners();
      });
    } else if (data.containsKey("broup_name")) {
      print("broup has changed!");
      print(data);
      Broup broup = getBroup(data);
      print("first get a copy of the old broup so we can see if a bro was added or removed");
      Broup oldBroup = broList.getChat(broup.id, broup.broup) as Broup;
      print("length of old broup ${oldBroup.participants.length} and length of new broup ${broup.participants.length}");
      print("length of broupBros of old broup: ${oldBroup.getBroupBros().length}");
      print("length of broupBros of New broup (we expect it to be 0): ${broup.getBroupBros().length}");
      List<Bro> broupBros = oldBroup.getBroupBros();
      broList.chatChangedCheckForRemoved(broup, oldBroup, broupBros);
      broList.chatChangedCheckForAdded(broup.id, broup.getParticipants(), broup.getAdmins(), oldBroup.getParticipants(), broupBros);
      broList.updateBroupBrosAdmins(broupBros, broup.getAdmins());
      broList.updateAliases(broupBros);
      broup.setBroupBros(broupBros);
      print("length of broupBros of New broup (we expect it NOW to be the same as old broup and newbroup participants length): ${broup.getBroupBros().length}");
      broList.updateChat(broup);
      storage.updateChat(broup).then((chat) {
        print("we have updated the chat");
        notifyListeners();
      });
    }
  }

  void broAddedYou(data) {
    print("a bro has added you!");
    BroBros broBros = getBroBros(data);
    broList.addChat(broBros);
    storage.addChat(broBros).then((value) {
      broList.updateBroupBrosForBroBros(broBros);
      notifyListeners();
    });
  }

  Broup getBroup(data) {
    Broup broup = new Broup(
        data["id"],
        data["broup_name"],
        data["broup_description"],
        data["alias"],
        data["broup_colour"],
        data["unread_messages"],
        data["last_time_activity"],
        data["room_name"],
        0,
        data["mute"] ? 1 : 0,
        1,
        data["left"] ? 1 : 0);
    List<dynamic> broIds = data["bro_ids"];
    List<int> broIdList = broIds.map((s) => s as int).toList();
    broup.setParticipants(broIdList);
    List<dynamic> broAdminsIds = data["bro_admin_ids"];
    List<int> broAdminIdList = broAdminsIds.map((s) => s as int).toList();
    broup.setAdmins(broAdminIdList);
    return broup;
  }

  BroBros getBroBros(data) {
    return BroBros(
        data["bros_bro_id"],
        data["chat_name"],
        data["chat_description"],
        data["alias"],
        data["chat_colour"],
        data["unread_messages"],
        data["last_time_activity"],
        data["room_name"],
        data["blocked"] ? 1 : 0,
        data["mute"] ? 1 : 0,
        0
    );
  }

  void leaveRoomSolo(int broId) {
    if (joinedSoloRoom) {
      print("left the room");
      joinedSoloRoom = false;
      this.socket.emit(
        "leave_solo",
        {
          "bro_id": broId
        },
      );
      this.socket.off('message_event_bro_added_you');
      this.socket.off('message_event_added_to_broup');
      this.socket.off('message_event_chat_changed');
      this.socket.off('message_event_send_solo');
    }
  }
}
