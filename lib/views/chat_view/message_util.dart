import 'package:intl/intl.dart';

import '../../objects/bro.dart';
import '../../objects/broup.dart';
import '../../objects/me.dart';
import '../../objects/message.dart';
import '../../services/auth/auth_service_social.dart';
import '../../utils/storage.dart';


Future<bool> getBroupUpdate(Broup chat, Storage storage) async {
  if (chat.updateBroup) {
    chat.updateBroup = false;
    Broup? broupServer = await AuthServiceSocial().retrieveBroup(chat.broupId);
    if (broupServer != null) {
      // We have retrieved a new broup object,
      // but we want to update the existing one
      chat.updateBroupDataServer(broupServer);
      chat.updateBroup = false;
      storage.updateBroup(chat);
    }
    return true;
  }
  return true;
}

Future<bool> getBros(Broup chat, Storage storage, Me me) async {
  print("getting bros!!!!");
  // First retrieve from the db.
  if (chat.retrievedBros) {
    print("already retrieved");
    return true;
  }
  List<Bro> storageBros = await storage.fetchBros(chat.getBroIds());

  print("got bros from the db ${storageBros}");
  // Copy the list so you're not making changes.
  List<int> broIdsToRetrieveServer = [...chat.broIds];
  for (Bro bro in storageBros) {
    broIdsToRetrieveServer.remove(bro.id);
  }
  if (broIdsToRetrieveServer.contains(me.id)) {
    broIdsToRetrieveServer.remove(me.id);
  }

  // Then retrieve from the server the bros that have to be updated.
  List<Bro> brosServer = [];
  if (broIdsToRetrieveServer.isNotEmpty) {
    brosServer = await AuthServiceSocial().retrieveBros(broIdsToRetrieveServer);
  }

  print("got bros from the server ${brosServer}");
  for (Bro bro in brosServer) {
    // Check if the bro is already in the local database
    bool foundInDb = false;
    for (Bro storageBro in storageBros) {
      if (storageBro.id == bro.id) {
        storage.updateBro(bro);
        foundInDb = true;
        break;
      }
    }
    if (!foundInDb) {
      storage.addBro(bro);
    }
  }
  // merge lists with preference for the server data.
  chat.broupBros = removeBroDuplicates(brosServer, storageBros, storage);
  // You are also part of the bros
  chat.addBro(me);
  chat.retrievedBros = true;
  return true;
}

List<Bro> removeBroDuplicates(List<Bro> newBrosServer, List<Bro> newBrosDB, Storage storage) {
  // First update or insert the bro in the local DB.
  for (Bro serverBro in newBrosServer) {
    bool foundInDB = false;
    for (int i = 0; i < newBrosDB.length; i++) {
      if (newBrosDB[i].id == serverBro.id) {
        storage.updateBro(serverBro);
        foundInDB = true;
        break;
      }
    }
    if (!foundInDB) {
      storage.addBro(serverBro);
    }
  }
  // The list from the server is up to date,
  // but there might be more in the local database
  List<int> seenBroIds = newBrosServer.map((e) => e.id).toList();
  List<Bro> noDuplicates = newBrosServer.toList(growable: true);

  for (Bro bro in newBrosDB) {
    if (!seenBroIds.contains(bro.id)) {
      seenBroIds.add(bro.id);
      noDuplicates.add(bro);
    }
  }

  return noDuplicates;
}

Future<bool> getMessages(int page, Broup chat, Storage storage) async {
  bool allMessagesDBRetrieved = false;
  print("getting messages");
  List<Message> messagesServer = [];
  List<Message> messagesDB = [];

  // get messages from local db
  List<Message> localMessages = await storage.fetchMessages(chat.getBroupId(), 0);
  // Limit set to 50. If it retrieves less it means that it can't and all the messages have been retrieved.
  print("length of retrieved messages: ${localMessages.length}");
  if (localMessages.length != 50) {
    allMessagesDBRetrieved = true;
  }
  if (localMessages.length != 0) {
    messagesDB = localMessages;
  }
  // get messages from the server
  if (chat.newMessages) {
    print("get from server");
    List<Message> retrievedMessages = await AuthServiceSocial().retrieveMessages(chat.getBroupId(), chat.lastMessageId);

    if (retrievedMessages.isNotEmpty) {
      messagesServer = retrievedMessages;
      // The max id of the retrieved messages HAS to be the last message id
      chat.lastMessageId = messagesServer.fold(0, (max, message) => message.messageId > max ? message.messageId : max);
    }
  } else {
    print("no new messages");
    // When the page is loaded we consider all messages as read
    chat.readMessages();
  }

  mergeMessages(messagesServer + messagesDB, chat);

  return allMessagesDBRetrieved;
}

Future<bool> fetchExtraMessages(int offSet, Broup chat, Storage storage) async {
  bool allMessagesDBRetrieved = false;
  List<Message> newMessages = await storage.fetchMessages(chat.getBroupId(), offSet);
  // Limit set to 50. If it retrieves less it means that it can't
  // and all the messages have been retrieved.
  if (newMessages.length != 50) {
    allMessagesDBRetrieved = true;
  }
  if (newMessages.length != 0) {
    mergeMessages(newMessages, chat);
  }
  return allMessagesDBRetrieved;
}

mergeMessages(List<Message> incomingMessages, Broup chat) {
  List<Message> newMessages = removeDuplicates(incomingMessages, chat);
  if (chat.messages.length != 0 && newMessages.isNotEmpty) {
    // id 0 is a date tile
    int lastId = chat.messages[chat.messages.length - 1].messageId;
    if (lastId == 0) {
      lastId = chat.messages[chat.messages.length - 2].messageId;
    }
    if (lastId <= newMessages[0].messageId) {
      newMessages = newMessages.where((x) => x.messageId < lastId).toList();
    }
    chat.messages = chat.messages.where((x) => x.messageId != 0).toList();
  }
  chat.messages.addAll(newMessages);
  chat.messages.sort((b, a) => a.timestamp.compareTo(b.timestamp));
  // Set date tiles, but only if all the messages are retrieved

}

List<Message> removeDuplicates(List<Message> newMessages, Broup chat) {
  // It's possible that certain messages were already in the list
  List<int> seenMessageIds = chat.messages.map((e) => e.messageId).toList();
  List<Message> noDuplicates = [];

  for (Message message in newMessages) {
    if (!seenMessageIds.contains(message.messageId)) {
      seenMessageIds.add(message.messageId);
      noDuplicates.add(message);
    }
  }

  return noDuplicates;
}

setDateTiles(Broup chat) {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
  Message messageFirst = chat.messages.first;
  DateTime dayFirst = DateTime(messageFirst.getTimeStamp().year,
      messageFirst.getTimeStamp().month, messageFirst.getTimeStamp().day);
  String chatTimeTile = DateFormat.yMMMMd('en_US').format(dayFirst);

  String timeMessageFirst = DateFormat.yMMMMd('en_US').format(dayFirst);
  if (dayFirst == today) {
    timeMessageFirst = "Today";
  }
  if (dayFirst == yesterday) {
    timeMessageFirst = "Yesterday";
  }

  Message timeMessage = new Message(
    0,
    0,
    timeMessageFirst,
    "",
    DateTime.now().toUtc().toString(),
    null,
    true,
    chat.getBroupId(),
  );
  for (int i = 0; i < chat.messages.length; i++) {
    DateTime current = chat.messages[i].getTimeStamp();
    DateTime dayMessage = DateTime(current.year, current.month, current.day);
    String currentDayMessage = DateFormat.yMMMMd('en_US').format(dayMessage);

    if (chatTimeTile != currentDayMessage) {
      chatTimeTile = DateFormat.yMMMMd('en_US').format(dayMessage);

      String timeMessageTile = chatTimeTile;
      if (dayMessage == today) {
        timeMessageTile = "Today";
      }
      if (dayMessage == yesterday) {
        timeMessageTile = "Yesterday";
      }

      if (timeMessage.body == "Today") {
        if (!chat.todayTileAdded) {
          chat.todayTileAdded = true;
          chat.messages.insert(i, timeMessage);
        }
      } else {
        chat.messages.insert(i, timeMessage);
      }

      chat.messages.insert(i, timeMessage);
      timeMessage = new Message(
        0,
        0,
        timeMessageTile,
        "",
        DateTime.now().toUtc().toString(),
        null,
        true,
        chat.getBroupId(),
      );
    }
  }

  if (timeMessage.body == "Today") {
    if (!chat.todayTileAdded) {
      chat.todayTileAdded = true;
      chat.messages.insert(chat.messages.length, timeMessage);
    }
  } else {
    chat.messages.insert(chat.messages.length, timeMessage);
  }
}