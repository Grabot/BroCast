import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/get_broup_bros.dart';
import 'package:brocast/services/settings.dart';

class BroList {
  static final BroList _instance = BroList._internal();

  late Settings settings;
  late GetBroupBros getBroupBros;
  late List<Chat> bros;

  BroList._internal() {
    settings = Settings();
    getBroupBros = GetBroupBros();
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

  void updateChat(Chat chat) {
    bros[bros.indexWhere((bro) =>
          bro.id == chat.id && bro.broup == chat.broup)] = chat;
  }

  getParticipantsInBroups() {
    print("getting participants in the broup");
    for (Chat broup in bros) {
      if (broup.isBroup()) {
        print("found a broup to update");
        // We will retrieve the participants for the broups that the bro is in.
        getParticipants(broup as Broup, broup.getParticipants(), broup.getAdmins());
      }
    }
  }

  getParticipants(Broup broup, List<int> participants, List<int> admins) {
    print("getting participants $participants");
    List<int> remainingParticipants = new List<int>.from(participants);
    List<int> remainingAdmins = new List<int>.from(admins);
    // List<Bro> foundParticipants = [];
    // We will reform the list. First me, than the admins than the rest
    List<Bro> broupMe = [];
    List<Bro> foundBroupAdmins = [];
    List<Bro> foundBroupNotAdmins = [];

    // I have to be in the array or participants, since I am in this broup.
    Bro? me = settings.getMe();
    // This is always called after the object is filled
    Bro meBroup = me!.copyBro();
    meBroup.broupId = broup.id;
    print("found me ${meBroup.getFullName()}");
    if (remainingAdmins.contains(meBroup.id)) {
      meBroup.setAdmin(true);
      remainingAdmins.remove(meBroup.id);
      broup.setAmIAdmin(true);
    } else {
      broup.setAmIAdmin(false);
    }
    broupMe.add(meBroup);
    remainingParticipants.remove(settings.getBroId());

    for (Chat br0 in bros) {
      if (!br0.isBroup()) {
        if (remainingParticipants.contains(br0.id)) {
          BroAdded broAdded = new BroAdded(br0.id, broup.id, br0.chatName);
          if (remainingAdmins.contains(br0.id)) {
            broAdded.setAdmin(true);
            remainingAdmins.remove(br0.id);
            foundBroupAdmins.add(broAdded);
          } else {
            foundBroupNotAdmins.add(broAdded);
          }
          remainingParticipants.remove(br0.id);
          print("found someone in our own list and removing it! ${br0.getBroNameOrAlias()}");
        }
      }
    }

    print("remainingParticipants $remainingParticipants");
    if (remainingParticipants.length != 0) {
      getBroupBros.getBroupBros(
          settings.getToken(), broup.id, remainingParticipants).then((value) {
        if (value != "an unknown error has occurred") {
          List<Bro> notAddedBros = value;
          for (Bro br0 in notAddedBros) {
            if (remainingAdmins.contains(br0.id)) {
              br0.setAdmin(true);
              remainingAdmins.remove(br0.id);
              foundBroupAdmins.add(br0);
            } else {
              foundBroupNotAdmins.add(br0);
            }
            remainingParticipants.remove(br0.id);
          }
          // The list can't be empty if everything was retrieved correctly.
          if (remainingParticipants.length != 0) {
            print("big error! Fix it!");
          }
          broup.setBroupBros(broupMe + foundBroupAdmins + foundBroupNotAdmins);
          // return broup;
        }
      });
    } else {
      // The list can't be empty if everything was retrieved correctly.
      if (remainingParticipants.length != 0) {
        print("big error! Fix it!");
      }
      broup.setBroupBros(broupMe + foundBroupAdmins + foundBroupNotAdmins);
      // return broup;
    }
    // Test if the broup object is updated in the list.
    // return broup;
  }
}
