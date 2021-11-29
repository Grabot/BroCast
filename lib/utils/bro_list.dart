import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/bro_not_added.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/get_broup_bros.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/storage.dart';

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
      storage.addBro(meBroup).then((value) {
        print("we have added yourself to the db for the broup!");
      });
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
