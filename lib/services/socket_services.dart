import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketServices extends ChangeNotifier {

  late IO.Socket socket;
  late Storage storage;
  late BroList broList;
  late Settings settings;

  bool joinedSoloRoom = false;

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    storage = Storage();
    broList = BroList();
    settings = Settings();
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
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
      print("joined the room");
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
    Broup broup = getBroup(data);
    broList.addChat(broup);
    storage.addChat(broup).then((value) {
      notifyListeners();
    });
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
      broList.updateChat(broup);
      if (oldBroup.participants.length > broup.participants.length) {
        // A bro was removed
        List<int> removedBro = new List<int>.from(oldBroup.participants);
        removedBro.removeWhere((broId) => broup.participants.contains(broId));
        // There should always be 1 removed
        print(removedBro);
        for (int removedBroId in removedBro) {
          print("removing bro id ${removedBroId.toString()} from broup with id ${broup.id.toString()}");
          storage.deleteBro(removedBroId.toString(), broup.id.toString()).then((value) {
            print("we have removed a bro from the db!");
          });
        }
      }
      List<int> addedBro = [];
      if (oldBroup.participants.length < broup.participants.length) {
        // A bro was added
        addedBro = new List<int>.from(broup.participants);
        addedBro.removeWhere((broId) => oldBroup.participants.contains(broId));
        // There should always be 1 added
        print(addedBro);
      }
      broList.getParticipants(broup, broup.getParticipants(), broup.getAdmins());
      for (Bro bro in broup.getBroupBros()) {
        if (addedBro.contains(bro.id)) {
          // This bro is not yet in the db.
          print("adding the bro ${bro.id}");
          storage.addBro(bro).then((value) {
            print("we have successfully added a bro");
          });
        } else {
          storage.updateBro(bro).then((bro) {
            print("we have updated a bro in the broup");
          });
        }
      }
      storage.updateChat(broup).then((chat) {
        print("we have updated the chat");
        notifyListeners();
      });
    }
  }

  void broAddedYou(data) {
    BroBros broBros = getBroBros(data);
    broList.addChat(broBros);
    storage.addChat(broBros).then((value) {
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
        1);
    List<dynamic> broIds = data["bro_ids"];
    List<int> broIdList = broIds.map((s) => s as int).toList();
    broup.setParticipants(broIdList);
    List<dynamic> broAdminsIds = data["bro_admin_ids"];
    List<int> broAdminIdList = broAdminsIds.map((s) => s as int).toList();
    broup.setAdmins(broAdminIdList);
    // TODO: @Skools retrieve Bro details here already?
    // broup = getParticipants(broup, broIdList, broAdminIdList);
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
    if (!joinedSoloRoom) {
      print("left the room");
      joinedSoloRoom = false;
      this.socket.emit(
        "leave_solo",
        {
          "bro_id": broId
        },
      );
      this.socket.off('message_event_bro_added_you');
      this.socket.off('message_event_send_solo');
    }
  }
}
