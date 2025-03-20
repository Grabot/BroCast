import 'package:brocast/constants/base_url.dart';
import 'package:brocast/services/auth/auth_service_social.dart';
import 'package:brocast/utils/socket_services_util.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../objects/message.dart';
import '../objects/broup.dart';
import '../objects/me.dart';
import '../services/auth/auth_service_login.dart';
import 'storage.dart';
import 'settings.dart';

class SocketServices extends ChangeNotifier {
  late io.Socket socket;

  bool joinedSoloRoom = false;

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    startSockConnection();
  }

  int changedBroupAvatar = -1;

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
      // We are connected, this is good :)
      // But it's also possible something went wrong in the backend?
      // So rejoin the channels and rooms
      Me? me = Settings().getMe();
      if (me != null) {
        joinRooms(me);
      }
    });

    socket.onDisconnect((_) {
      socket.emit('message_event', 'Disconnected!');
    });

    socket.on('message_event', (data) {
      print("message event $data");
      checkMessageEvent(data);
    });

    socket.open();
  }

  joinRooms(Me me) {
    // First leave all rooms, to be sure.
    leaveRoomSolo(me.getId());
    for (Broup meBroup in me.broups) {
      leaveRoomBroup(meBroup.getBroupId());
    }
    // rejoin all socket rooms.
    joinRoomSolo(me.getId());
    joinedSoloRoom = true;
    for (Broup meBroup in me.broups) {
      if (!meBroup.removed && !meBroup.deleted) {
        joinRoomBroup(meBroup.getBroupId());
        meBroup.joinedBroupRoom = true;
      }
    }
  }

  retrieveAvatar() {
    AuthServiceLogin().getAvatarMe().then((value) {
      if (value) {
        notifyListeners();
      }
    }).onError((error, stackTrace) {
      // TODO: What to do on an error? Reset?
    });
  }

  void checkMessageEvent(data) {
    if (data == "Avatar creation done!") {
      retrieveAvatar();
    }
  }

  bool isConnected() {
    return socket.connected;
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

  checkAvatarChange(data) {
    // TODO: Check when using server?
    // Here we indicate that an avatar is changed such that we can retrieve it.
    print("Avatar changed $data");
    Me? me = Settings().getMe();
    if (me != null) {
      if (data.containsKey("broup_id")) {
        int broupId = data["broup_id"];
        AuthServiceSocial().getAvatarBroup(broupId).then((value) {
          if (value) {
            notifyListeners();
          }
        });
      }
      if (data.containsKey("bro_id")) {
        int broId = data["bro_id"];
        AuthServiceSocial().getAvatarBro(broId).then((value) {
          if (value) {
            notifyListeners();
          }
        });
      }
    }
  }

  chatChanged(data) async {
    print("chat changed $data");
    int broupId = data["broup_id"];
    Me? me = Settings().getMe();
    if (me != null) {
      Broup broup = me.broups.firstWhere((element) => element.broupId == broupId);
      // blocked is the flag if you blocked to other. removed is the flag if you are blocked
      if (broup.removed && !broup.deleted) {
        if (data.containsKey("chat_blocked")) {
          bool chatBlocked = data["chat_blocked"];
          if (broup.private && !chatBlocked) {
            // I am unblocked!
            broup.blocked = false;
            broup.removed = false;
            broup.adminIds = [];
            addInformationMessage(broup, "Chat is unblocked! 🥰");
            if (!broup.joinedBroupRoom) {
              broup.joinedBroupRoom = true;
              joinRoomBroup(broup.broupId);
            }
            notifyListeners();
          }
        }
      } else if (broup.blocked || broup.deleted) {
        return;
      } else {
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
            broup.unreadMessages = 0;
            // We leave the socket to not receive broup updates anymore.
            if (broup.joinedBroupRoom) {
              broup.joinedBroupRoom = false;
              leaveRoomBroup(broup.broupId);
            }
          }
        }
        if (data.containsKey("broup_updated")) {
          // probably True, we should update broup
          bool broupUpdated = data["broup_updated"];
          broup.setUpdateBroup(broupUpdated);
        }

        if (data.containsKey("chat_blocked")) {
          // Block chat can only be a private chat
          bool chatBlocked = data["chat_blocked"];
          if (broup.private && chatBlocked) {
            // In a private chat both chats will be blocked
            broup.removed = true;
            broup.unreadMessages = 0;
            // We leave the socket to not receive broup updates anymore.
            if (broup.joinedBroupRoom) {
              broup.joinedBroupRoom = false;
              leaveRoomBroup(broup.broupId);
            }
          }
        }
        if (data.containsKey("new_avatar")) {
          print("gotten a new avatar for a broup!");
          bool newAvatar = data["new_avatar"];
          // We assume the newAvatar is True
          print(
              "gotten a new avatar! $newAvatar  $changedBroupAvatar  $broupId");
          // If changedBroupAvatar is equal to the broupId
          // it means we just changed it ourselves.
          if (newAvatar && !(changedBroupAvatar == broupId)) {
            AuthServiceSocial().getAvatarBroup(broupId).then((value) {
              if (value) {
                // Objects updated in db and on the `me` list.
                notifyListeners();
              }
            });
          } else if (changedBroupAvatar == broupId) {
            // We just changed the avatar, so we set it back to -1.
            print("setting it back to -1");
            changedBroupAvatar = -1;
          }
        }
        Storage().updateBroup(broup);
        notifyListeners();
      }
    }
  }

  setWeChangedAvatar(int avatarBroupId) {
    print("changing we avatar $avatarBroupId");
    changedBroupAvatar = avatarBroupId;
    // Put it back after 5 seconds, this should be enough time to
    // ignore incoming socket updates and not interfere with
    // future socket updates in the same broup
    Future.delayed(Duration(seconds: 5)).then((value) {
      if (changedBroupAvatar != -1) {
        changedBroupAvatar = -1;
      }
    });
  }

  chatAdded(data) async {
    print("chat added $data");
    // TODO: If you received the broup via sockets we should set `broup_updated` to false?
    Me? me = Settings().getMe();
    if (me != null) {
      // Add the broup. If it already exists, for instance because we left or were removed
      // we will add it as normal and it will be replaced and updated.
      if (data.containsKey("broup")) {
        Broup newBroup = Broup.fromJson(data["broup"]);
        Storage().addBroup(newBroup);
        me.addBroup(newBroup);

        if (newBroup.private) {
          for (int broId in newBroup.broIds) {
            if (broId != me.getId()) {
              // For private chats we want to retrieve the bro object.
              // TODO: Check if the bro is already in storage?
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
        } else {
          // Retrieve avatar (in private chats, it's the avatar of the bro)
          // Give some delay to make sure the avatar is created.
          Future.delayed(Duration(seconds: 2)).then((value) {
            AuthServiceSocial().getAvatarBroup(newBroup.broupId).then((value) {
              if (value) {
                // Data is retrieved, and updated on the broup db object.
                notifyListeners();
              }
            });
          });
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
      print("going to check broup!");
      Broup broup = me.broups.firstWhere((element) => element.broupId == broupId);
      // Always add the message, if the broup is removed it should not be listening to the sockets anymore.
      broup.updateMessages(message);
      storage.updateBroup(broup);
      notifyListeners();
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
      if (data.containsKey("new_avatar")) {
        print("gotten a new avatar! ");
        int broId = data["bro_id"];
        bool newAvatar = data["new_avatar"];
        // We assume the newAvatar is True
        print("gotten a new avatar! $newAvatar");
        if (newAvatar) {
          AuthServiceSocial().getAvatarBro(broId).then((value) {
            if (value) {
              notifyListeners();
              // The bro is stored in the db. We retrieve it and update the corresponding broups.
              // TODO: notify the server that new_avatar is done?
            }
          });
        }
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
    this.socket.on('avatar_change', (data) {
      checkAvatarChange(data);
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
