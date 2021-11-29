import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/bro_bros.dart';
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
  late Settings settings;
  late GetBroupBros getBroupBros;

  bool joinedSoloRoom = false;

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    storage = Storage();
    broList = BroList();
    settings = Settings();
    getBroupBros = GetBroupBros();
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
    print("added a broup, getting information!");
    Broup broup = getBroup(data);
    print("length of broupbros before: ${broup.getBroupBros()}");
    List<Bro> broupBros = [];
    // We assume this object is always filled an always in the participant list.
    chatChangedCheckForAdded(broup.id, broup.getParticipants(), broup.getAdmins(), [], broupBros);
    broup.setBroupBros(broupBros);
    print("length of broupbros after: ${broup.getBroupBros()}");
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
      print("length of broupBros of old broup: ${oldBroup.getBroupBros().length}");
      print("length of broupBros of New broup (we expect it to be 0): ${broup.getBroupBros().length}");
      List<Bro> broupBros = oldBroup.getBroupBros();
      chatChangedCheckForRemoved(broup, oldBroup, broupBros);
      chatChangedCheckForAdded(broup.id, broup.getParticipants(), broup.getAdmins(), oldBroup.getParticipants(), broupBros);
      updateBroupBrosAdmins(broupBros, broup.getAdmins());
      broup.setBroupBros(broupBros);
      print("length of broupBros of New broup (we expect it NOW to be the same as old broup and newbroup participants length): ${broup.getBroupBros().length}");

      broList.updateChat(broup);
      // All the bro's should be in the db so we update all of them
      // In case, for instance, if someone became admin
      for (Bro bro in broup.getBroupBros()) {
        storage.updateBro(bro).then((bro) {
          print("we have updated a bro in the broup");
        });
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

  chatChangedCheckForRemoved(Broup newBroup, Broup oldBroup, List<Bro> broupBros) {
    // Check if bro's was removed
    List<int> removedBros = new List<int>.from(oldBroup.participants);
    removedBros.removeWhere((broId) => newBroup.participants.contains(broId));
    print(removedBros);
    // Remove the bro's that have been removed from the db for this broup
    for (int removedBroId in removedBros) {
      print("removing bro id ${removedBroId.toString()} from broup with id ${newBroup.id.toString()}");
      storage.deleteBro(removedBroId.toString(), newBroup.id.toString()).then((value) {
        print("we have removed a bro from the db!");
      });
      print("also remove it from our list of bros");
      broupBros.removeWhere((broupBro){
        return broupBro.id == removedBroId;
      });
    }
  }

  chatChangedCheckForAdded(int broupId, List<int> newBroupP, List<int> newBroupA, List<int> oldBroupP, List<Bro> broupBros) {
    // bro's that were added
    List<int> addedBro = new List<int>.from(newBroupP);
    List<int> remainingAdmins = new List<int>.from(newBroupA);
    addedBro.removeWhere((broId) => oldBroupP.contains(broId));
    print(addedBro);

    if (addedBro.contains(settings.getBroId())) {
      // If you are added to a new bro you will be in the addedBro list.
      // Make an object for yourself as well.
      BroAdded? me = settings.getMe();
      BroAdded meBroup = me!.copyBro();
      if (remainingAdmins.contains(meBroup.id)) {
        meBroup.setAdmin(true);
        meBroup.broupId = broupId;
        remainingAdmins.remove(meBroup.id);
      }
      broupBros.add(meBroup);
      addedBro.remove(settings.getBroId());
      storage.addBro(meBroup).then((value) {
        print("we have added yourself to the db for the broup!");
      });
    }

    // We look in our list of bros to see if we find the added bros
    // If that is the case than the bro's are BroAdded Bro's
    // If not than we have to retrieve the information and they are BroNotAdded
    for (Chat bro in broList.getBros()) {
      if (!bro.isBroup()) {
        if (addedBro.contains(bro.id)) {
          BroAdded broAdded = new BroAdded(bro.id, broupId, bro.chatName);
          if (remainingAdmins.contains(bro.id)) {
            broAdded.setAdmin(true);
            remainingAdmins.remove(bro.id);
          }
          storage.addBro(broAdded).then((value) {
            print("we have added a bro from the db!");
          });
          broupBros.add(broAdded);
          addedBro.remove(bro.id);
        }
      }
    }

    print("addedBro remaing $addedBro");
    if (addedBro.length != 0) {
      getBroupBros.getBroupBros(
          settings.getToken(), broupId, addedBro).then((value) {
        if (value != "an unknown error has occurred") {
          List<Bro> notAddedBros = value;
          for (Bro broNotAdded in notAddedBros) {
            if (remainingAdmins.contains(broNotAdded.id)) {
              broNotAdded.setAdmin(true);
              remainingAdmins.remove(broNotAdded.id);
            }
            storage.addBro(broNotAdded).then((value) {
              print("we have added a bro from the db!");
            });
            broupBros.add(broNotAdded);
            addedBro.remove(broNotAdded.id);
          }
          // The list can't be empty if everything was retrieved correctly.
          if (addedBro.length != 0) {
            print("big error! Fix it!");
          }
        }
      });
    }
  }

  updateBroupBrosAdmins(List<Bro> broupBros, List<int> admins) {
    List<int> remainingAdmins = new List<int>.from(admins);
    for (Bro bro in broupBros) {
      // We want to see who is admin and who isn't.
      // To do this we always say they aren't an admin first,
      // but if they are in the admin list we set it to true again.
      // This should ensure that new admins are marked as admin,
      // but people who no longer are admin will loose their admin status in the Bro object.
      bro.setAdmin(false);
      if (remainingAdmins.contains(bro.id)) {
        bro.setAdmin(true);
        remainingAdmins.remove(bro.id);
      }
    }
    print("we've covered all Bro's length: ${remainingAdmins.length}");
  }
}
