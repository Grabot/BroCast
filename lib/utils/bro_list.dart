import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/bro_not_added.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/get_bros.dart';
import 'package:brocast/services/get_broup_bros.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/storage.dart';
import 'package:collection/collection.dart';


class BroList {
  static final BroList _instance = BroList._internal();

  late Settings settings;
  late Storage storage;
  late GetBroupBros getBroupBros;
  late List<Chat> bros;

  BroList._internal() {
    settings = Settings();
    getBroupBros = GetBroupBros();
    storage = Storage();
    bros = [];
  }

  factory BroList() {
    return _instance;
  }


  Future<bool> searchBros(String token) async {
    GetBros getBros = new GetBros();
    return getBros.getBros(token).then((bros) {
      if (!(bros is String)) {
        // We have retrieved all the bros and broups.
        // We will remove the chat database and refill it.

        for (Chat chat in bros) {
          storage.selectChat(chat.id.toString(), chat.broup.toString()).then((value) {
            if (value == null) {
              storage.addChat(chat).then((value) {
                print("added a chat that was added since you were away");
              });
            } else {
              storage.updateChat(chat).then((value) {
                print("a chat was updated!");
              });
            }
          });
        }
        this.bros = bros;
        return true;
      } else {
        return false;
      }
    });
  }

  List<Chat> getBros() {
    return this.bros;
  }

  void setBros(List<Chat> bros) {
    this.bros = bros;
  }

  void addChat(Chat chat) {
    this.bros.add(chat);
  }

  Chat getChat(int chatId, int broup) {
    return bros[bros.indexWhere((bro) => bro.id == chatId && bro.broup == broup)];
  }

  void updateChat(Chat chat) {
    bros[bros.indexWhere((bro) =>
          bro.id == chat.id && bro.broup == chat.broup)] = chat;
  }

  updateBroupBrosForBroBros(BroBros broBros) {
    // After the chat is saved we will go through the broups to find if we need to update some entries
    for (Chat broup in bros) {
      if (broup.isBroup()) {
        for (Bro bro in (broup as Broup).getBroupBros()) {
          if (bro is BroNotAdded) {
            // We only check the not added bro's since we've might have added them.
            if (broBros.id == bro.id) {
              // If we have found one that is the same bro we should update it to a BroAdded
              print("found one to be updated!");
              BroAdded updatedBro = new BroAdded(bro.id, broup.id, broBros.chatName);
              updatedBro.setAdmin(bro.isAdmin());
              print("name: ${updatedBro.chatName}");
              // Because it has the same id and broupid it should be updated in the db.
              storage.updateBro(updatedBro, broup.id.toString()).then((value) {
                print("The added bro is successfully updated in a broup object");
              });
            }
          }
        }
      }
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

  chatCheckForDBRemoved(int broupId, List<int> participants) {
    storage.fetchAllBrosOfBroup(broupId.toString()).then((broupBros) {
      // We assume all the bros are present in the list. But it's possible there are some extra bros in the db.
      // When someone is removed from the db it is retrieved successfully and not shown, but the entry is still in the db.
      // If we find some of those entries, we will remove them
      for (Bro bro in broupBros) {
        if (!participants.contains(bro.id)) {
          storage.deleteBro(bro.id.toString(), bro.broupId.toString()).then((value) {
            print("we had to remove a bro unfortunately.");
          });
        }
      }
    });
  }

  insertOrUpdateBro(Bro bro) {
    storage.selectBro(bro.id.toString(), bro.broupId.toString()).then((value) {
      if (value == null) {
        storage.addBro(bro).then((value) {
          print("we have added a bro to the db for the broup!");
          print("broupid ${bro.broupId}");
          print("bro id ${bro.id}");
        });
      } else {
        storage.updateBro(bro, bro.broupId.toString()).then((value) {
          print("we have updated a bro to the db for the broup!");
        });
      }
    });
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
        remainingAdmins.remove(meBroup.id);
      }
      meBroup.broupId = broupId;
      broupBros.add(meBroup);
      addedBro.remove(settings.getBroId());
      insertOrUpdateBro(meBroup);
    }

    // We look in our list of bros to see if we find the added bros
    // If that is the case than the bro's are BroAdded Bro's
    // If not than we have to retrieve the information and they are BroNotAdded
    for (Chat bro in bros) {
      if (!bro.isBroup()) {
        if (addedBro.contains(bro.id)) {
          BroAdded broAdded = new BroAdded(bro.id, broupId, bro.chatName);
          if (remainingAdmins.contains(bro.id)) {
            broAdded.setAdmin(true);
            remainingAdmins.remove(bro.id);
          }
          insertOrUpdateBro(broAdded);
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
            insertOrUpdateBro(broNotAdded);
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
    print("updating broup bro admins");
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
      insertOrUpdateBro(bro);
    }
    print("we've covered all Bro's length: ${remainingAdmins.length}");
  }

  updateAliases(List<Bro> broupBros) {
    for (Chat bro in bros) {
      if (!bro.isBroup()) {
        Bro? check = broupBros.firstWhereOrNull((element) => bro.id == element.id);
        if (check != null && check is BroAdded) {
          // It's possible that you have given this bro an alias.
          // We want to see this instead of the actual name,
          // so update it on this object.
          if (check.getFullName() != bro.getBroNameOrAlias()) {
            check.setFullName(bro.getBroNameOrAlias());
            insertOrUpdateBro(check);
          }
        }
      }
    }
  }
}
