import 'package:brocast/constants/base_url.dart';
import 'package:brocast/services/auth/v1_4/auth_service_social.dart';
import 'package:brocast/services/auth/v1_5/auth_service_social_v1_5.dart';
import 'package:collection/collection.dart';
import 'package:brocast/utils/socket_services_util.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import 'package:brocast/views/chat_view/messaging_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../objects/message.dart';
import '../objects/broup.dart';
import '../objects/me.dart';
import '../services/auth/v1_4/auth_service_login.dart';
import 'location_sharing.dart';
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

  void startSocketConnection() {
    if (!socket.connected) {
      socket.connect();
      Me? me = Settings().getMe();
      if (me != null) {
        joinRooms(me);
      }
    }
  }

  startSockConnection() {
    String socketUrl = baseUrl_v1_0;
    socket = io.io(socketUrl, <String, dynamic>{
      'autoConnect': false,
      'path': "/socket.io",
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      // Rejoin the channels and rooms
      Me? me = Settings().getMe();
      if (me != null) {
        joinRooms(me);
      }
    });

    socket.onDisconnect((_) {});

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
    checkShareLocation();
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
    // Here we indicate that an avatar is changed such that we can retrieve it.
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
        if (Settings().getMe()!.id == broId) {
          AuthServiceLogin().getAvatarMe().then((value) {
            if (value) {
              notifyListeners();
            }
          });
        } else {
          AuthServiceSocial().getAvatarBro(broId).then((value) {
            if (value) {
              notifyListeners();
            }
          });
        }
      }
    }
  }

  chatChanged(data) async {
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
            broup.newMessages = true;
            broup.updateBroup = true;
            broup.adminIds = [];
            if (!broup.joinedBroupRoom) {
              broup.joinedBroupRoom = true;
              joinRoomBroup(broup.broupId);
            }
            Storage().updateBroup(broup);
            notifyListeners();
            return;
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
          // We check if we have the bro in the database, otherwise we add it to the updateBros on the broup
          if (!broup.broIds.contains(newMemberId)) {
            broup.broIds.add(newMemberId);
          }
          if (!broup.updateBroIds.contains(newMemberId)) {
            broup.updateBroIds.add(newMemberId);
          }
          if (!broup.updateBroAvatarIds.contains(newMemberId)) {
            broup.updateBroAvatarIds.add(newMemberId);
          }
          Storage().updateBroup(broup);
          broup.checkedRemainingBros = false;
          if (Settings().getMe()!.getId() == newMemberId) {
            broup.removed = false;
          }
          MessagingChangeNotifier().notify();
        }
        if (data.containsKey("new_admin_id")) {
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
          if (broup.updateBroIds.contains(removedBroId)) {
            broup.updateBroIds.remove(removedBroId);
          }
          if (broup.updateBroAvatarIds.contains(removedBroId)) {
            broup.updateBroAvatarIds.remove(removedBroId);
          }
          broup.checkedRemainingBros = false;
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
        if (data.containsKey("bro_to_update")) {
          int broToUpdate = data["bro_to_update"];
          if (!broup.updateBroIds.contains(broToUpdate)) {
            broup.updateBroIds.add(broToUpdate);
          }
          // Check if it's open right now
          if (MessagingChangeNotifier().getBroupId() == broupId) {
            broup.checkedRemainingBros = false;
            MessagingChangeNotifier().notify();
          } else {
            broup.updateBroup = true;
          }
          notifyListeners();
          // TODO: signal server that the update is already done?
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
          bool newAvatar = data["new_avatar"];
          broup.newAvatar = newAvatar;
          // We assume the newAvatar is True
          // If changedBroupAvatar is equal to the broupId
          // it means we just changed it ourselves.
          if (newAvatar && !(changedBroupAvatar == broupId)) {
            Future.delayed(Duration(seconds: 2)).then((value) {
              // It might be send via sockets during the delay, in that case don't retrieve it again.
              // In that case the `newAvatar` is set to false.
              Broup checkBroup = me.broups.firstWhere((element) => element.broupId == broupId);
              if (checkBroup.newAvatar) {
                AuthServiceSocial().getAvatarBroup(broupId).then((value) {
                  if (value) {
                    // Objects updated in db and on the `me` list.
                    notifyListeners();
                  }
                });
              }
            });
          } else if (changedBroupAvatar == broupId) {
            // We just changed the avatar, so we set it back to -1.
            changedBroupAvatar = -1;
          }
        }
      }

      AuthServiceSocial().broupRetrieved(broup.broupId).then((value) {
        if (value) {
          broup.updateBroup = false;
          Storage().updateBroup(broup);
          notifyListeners();
        }
      });
    }
  }

  setWeChangedAvatar(int avatarBroupId) {
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
    Me? me = Settings().getMe();
    if (me != null) {
      // Add the broup. If it already exists, for instance because we left or were removed
      // we will add it as normal and it will be replaced and updated.
      if (data.containsKey("broup")) {
        Broup newBroup = Broup.fromJson(data["broup"]);
        // It's possible that the broup already exists, like when you were blocked
        // In that case we want to override the existing object to ensure a smooth experience.
        bool found = false;
        // We want to mark the bros we don't know yet to be updated.
        for (Broup meBroup in me.broups) {
          if (meBroup.broupId == newBroup.broupId) {
            meBroup.updateBroupDataServer(newBroup);
            newBroup = meBroup;
            found = true;
            // We should have left already, but to be sure do it again.
            leaveRoomBroup(meBroup.broupId);
            // Join the broup room again after a slight delay.
            Future.delayed(Duration(milliseconds: 200)).then((value) {
              joinRoomBroup(meBroup.broupId);
            });
            break;
          }
        }

        int localLastMessageReadId = 1;
        if (data["broup"].containsKey("chat")) {
          if (data["broup"]["chat"].containsKey("current_message_id")) {
            localLastMessageReadId = data["broup"]["chat"]["current_message_id"];
          }
        }
        newBroup.localLastMessageReadId = localLastMessageReadId;
        newBroup.lastMessageReadId = localLastMessageReadId;
        newBroup.lastMessageId = localLastMessageReadId;

        // Check the bros I have to update.
        if (!newBroup.private) {
          List<int> brosToUpdate = [...newBroup.getBroIds()];
          for (Broup meBroupAgain in me.broups) {
            if (meBroupAgain.private) {
              for (int broId in meBroupAgain.broIds) {
                if (brosToUpdate.contains(broId)) {
                  // This means we know the bro, so we don't mark it for update.
                  brosToUpdate.remove(broId);
                }
              }
            }
          }
          if (brosToUpdate.isNotEmpty) {
            newBroup.updateBroIds = brosToUpdate;
            newBroup.updateBroAvatarIds = brosToUpdate;
          }
        }
        if (!found) {
          me.addBroup(newBroup);
          Storage().addBroup(newBroup);
        } else {
          Storage().updateBroup(newBroup);
        }

        if (newBroup.private) {
          for (int broId in newBroup.broIds) {
            if (broId != me.getId()) {
              // For private chats we want to retrieve the bro object.
              AuthServiceSocial().retrieveBroAvatar(broId).then((bro) {
                if (bro != null) {
                  newBroup.addBro(bro);
                  // Since we retrieved everything from the bro we will add it.
                  // If it exists it will be overridden.
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
          // For a new broup we should always retrieve the avatar.
          Future.delayed(Duration(seconds: 2)).then((value) {
            // It might be send via sockets during the delay, in that case don't retrieve it again.
            bool avatarRetrieved = false;
            for (Broup meBroup in me.broups) {
              if (meBroup.broupId == newBroup.broupId) {
                if (meBroup.avatar != null) {
                  avatarRetrieved = true;
                  break;
                }
              }
            }
            if (!avatarRetrieved) {
              AuthServiceSocial().getAvatarBroup(newBroup.broupId).then((value) {
                if (value) {
                  // Data is retrieved, and updated on the broup db object.
                  notifyListeners();
                }
              });
            }
          });
        }
        // Broup is added and all the data will be retrieved, so mark the broup as updated.
        AuthServiceSocial().broupRetrieved(newBroup.broupId).then((value) {
          if (value) {
            newBroup.updateBroup = false;
            Storage().updateBroup(newBroup);
            notifyListeners();
          }
        });
      }
    }
    BroHomeChangeNotifier().notify();
  }

  emojiReactionReceived(data) async {
    int broupId = data["broup_id"];
    int messageId = data["message_id"];
    String emoji = data["emoji"];
    int broId = data["bro_id"];
    bool isAdd = true;
    if (data.containsKey("is_add")) {
      isAdd = data["is_add"];
    }
    Me? me = Settings().getMe();
    if (me != null) {
      Broup? broup = me.broups.firstWhereOrNull((element) => element.broupId == broupId);
      if (broup != null) {
        // The message might not be loaded on the broup, so retrieve it from storage
        Storage().fetchMessageWithId(broupId, messageId).then((message) {
          if (message != null) {
            if (message.deleted) {
              return;
            }
            if (isAdd) {
              message.addEmojiReaction(emoji, broId);
            } else {
              message.removeEmojiReaction(broId);
            }
            Storage().updateMessage(message).then((value) {
              if (value > 0) {
                // update worked, so update the server that the emoji reaction was received
                AuthServiceSocialV15().receivedEmojiReaction(broupId).then((value) {
                });
              }
            });
            Message? messageInBroup = broup.messages.firstWhereOrNull((element) => element.messageId == messageId);
            if (messageInBroup != null) {
              // The only thing that changed is the emojiReactions, so we can just update that.
              messageInBroup.updateEmojiReactions(message.emojiReactions);
              notifyListeners();
            }
          } else {
            // The message is not yet in the local db,
            // it could be because the message is not retrieved yet.
            // Create a placeholder message with the emoji reactions.
            Message placeHolderMessage = Message(
                messageId: messageId,
                senderId: -1,
                body: "",
                textMessage: null,
                timestamp: DateTime.now().toUtc().toString(),
                data: null,
                dataType: null,
                repliedTo: null,
                info: false,
                broupId: broupId
            );
            placeHolderMessage.addEmojiReaction(emoji, broId);
            Storage().addMessage(placeHolderMessage);
            AuthServiceSocialV15().receivedEmojiReaction(broupId).then((value) {
              notifyListeners();
            });
          }
        });
      }
    }
  }

  messageReceived(data) async {
    Message message = await Message.fromJson(data);
    Storage storage = Storage();
    // We only want to do the receive update when the app is opened.
    int broupId = message.broupId;
    Me? me = Settings().getMe();
    if (me != null) {
      Broup broup = me.broups.firstWhere((element) => element.broupId == broupId);
      if (broup.sendingMessage) {
        // If we are sending a message we do not want to update the messages yet. Wait a bit and try again
        await Future.delayed(const Duration(milliseconds: 500));
        messageReceived(data);
        return;
      }
      broup.newMessages = true;
      Message? storageMessage;
      storageMessage = await storage.fetchMessageWithId(message.broupId, message.messageId);
      // We update the newly created message with data from what we retrieved locally.
      // We update it with data that is not sent over the socket and might already be stored locally.
      if (storageMessage != null) {
        message.dataType = storageMessage.dataType;
        message.data = storageMessage.data;
        message.repliedTo = storageMessage.repliedTo;
        message.emojiReactions = storageMessage.emojiReactions;
        await storage.updateMessage(message);
      } else {
        await storage.addMessage(message);
      }

      broup.updateMessages(message);
      broup.updateLastActivity(message.timestamp);
      storage.updateBroup(broup);
      notifyListeners();
    }
  }

  messageRead(data) async {
    int broupId = data["broup_id"];
    int lastMessageReadIdChat = data["last_message_read_id"];
    Me? me = Settings().getMe();
    if (me != null) {
      Storage storage = Storage();
      Broup broup = me.broups.firstWhere((element) => element.broupId == broupId);
      // We update the last message read id.
      broup.lastMessageReadId = lastMessageReadIdChat;
      // But maybe messages are already retrieved and we will update them.
      broup.updateLastReadMessages(lastMessageReadIdChat, storage);
      storage.updateBroup(broup);
      notifyListeners();
    }
  }

  broUpdated(data) async {
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
        int broId = data["bro_id"];
        // A different bro has changed their avatar.
        // We get it via the avatar created socket.
        if (Settings().getMe()!.getId() != broId) {
          // here it should have also send the broup_id to know which broup to update
          int broupId = data["broup_id"];
          Broup broup = me.broups.firstWhere((element) =>
          element.broupId == broupId);

          bool newAvatar = data["new_avatar"];
          // We assume the newAvatar is True, but check anyway
          if (newAvatar) {
            // In a private broup we update immediately, because the bro avatar is also the broup avatar
            if (broup.private) {
              AuthServiceSocial().getAvatarBro(broId).then((value) {
                if (value) {
                  // We mark the broup as updated, since all the data is retrieved.
                  // If any other data should have been retrieved, it was done so at startup
                  // Now the avatar is retrieved, which means the update broup can be set to false.
                  AuthServiceSocial().broupRetrieved(broup.broupId).then((value) {
                    if (value) {
                      broup.updateBroup = false;
                      Storage().updateBroup(broup);
                      notifyListeners();
                    }
                  });
                  notifyListeners();
                }
              });
            } else {
              // If it's a regular broup we will set the bro to be updated for when the broup is opened.
              if (!broup.updateBroAvatarIds.contains(broId)) {
                broup.updateBroAvatarIds.add(broId);
                Storage().updateBroup(broup);
              }
            }
          }
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
    this.socket.on('emoji_reaction', (data) {
      emojiReactionReceived(data);
    });
    this.socket.on('message_read', (data) {
      messageRead(data);
    });
    this.socket.on('avatar_change', (data) {
      checkAvatarChange(data);
    });
    this.socket.on('location_updated', (data) {
      locationUpdated(data);
    });
    this.socket.on('message_deleted', (data) {
      messageDeleted(data);
    });
  }

  joinSocketsBroup() {
  }

  leaveSocketsSolo() {
    this.socket.off('chat_changed');
    this.socket.off('chat_added');
    this.socket.off('bro_update');
    this.socket.off('message_received');
    this.socket.off('emoji_reaction');
    this.socket.off('message_read');
    this.socket.off('avatar_change');
    this.socket.off('location_updated');
    this.socket.off('message_deleted');
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

  notify() {
    notifyListeners();
  }

  updateLocation(int meId, int broupId, double lat, double lng) {
    this.socket.emit("update_location", {
      "bro_id": meId,
      "broup_id": broupId,
      "lat": lat,
      "lng": lng,
    });
  }

  locationUpdated(data) {
    if (data.containsKey("bro_id")
        && data.containsKey("lat")
        && data.containsKey("lng")) {
      int broId = data["bro_id"];
      Me? me = Settings().getMe();
      if (me != null) {
        LatLng latLng = LatLng(data["lat"], data["lng"]);
        LocationSharing().updateBroLocation(broId, latLng);
      }
    }
  }

  checkShareLocation() {
    LocationSharing locationSharing = LocationSharing();
    if (locationSharing.endTimeShareMe != {}) {
      Me? me = Settings().getMe();
      if (me != null) {
        locationSharing.startSharingAll(me);
      }
    }
  }

  messageDeleted(data) {
    if (data.containsKey("message_id") && data.containsKey("broup_id") && data.containsKey("deleted_by")) {
      int messageId = data["message_id"];
      int deletedByBroId = data["deleted_by"];
      int broupId = data["broup_id"];
      Storage().fetchMessageWithId(broupId, messageId).then((deleteMessage) {
        if (deleteMessage != null) {
          deleteMessage.deleted = true;
          deleteMessage.deletedByBroId = deletedByBroId;
          Storage().updateMessage(deleteMessage);
          Me? me = Settings().getMe();
          if (me != null) {
            Broup broup = me.broups.firstWhere((element) => element.broupId == broupId);
            broup.messages.removeWhere((element) => element.messageId == messageId);
            broup.messages.add(deleteMessage);
            broup.messages.sort((b, a) => a.getTimeStamp().compareTo(b.getTimeStamp()));
            notify();
          }
        } else {
          Message placeHolderDeleteMessage = Message(
              messageId: messageId,
              senderId: -1,
              body: "",
              textMessage: null,
              timestamp: DateTime.now().toUtc().toString(),
              data: null,
              dataType: null,
              repliedTo: null,
              info: false,
              broupId: broupId
          );
          placeHolderDeleteMessage.deleteMessageLocally(deletedByBroId);
          Storage().addMessage(placeHolderDeleteMessage);
          AuthServiceSocialV15().receivedDeletionMessage(broupId).then((value) {
            notifyListeners();
          });
        }
      });
    }
  }
}
