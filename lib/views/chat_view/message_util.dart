import 'package:intl/intl.dart';

import '../../objects/bro.dart';
import '../../objects/broup.dart';
import '../../objects/me.dart';
import '../../objects/message.dart';
import '../../services/auth/auth_service_social.dart';
import '../../utils/storage.dart';

Future<bool> getBroupDataBroup(Broup chat, Storage storage, Me? me) async {
  storage.fetchBroup(chat.broupId).then((broupDb) {
    storage.fetchBros(chat.broIds).then((brosDb) {
      Map<String, Bro> broMap = {for (var bro in brosDb) bro.getId().toString(): bro};
      if (me != null) {
        for (Broup meBroup in me.broups) {
          if (meBroup.broupId == chat.broupId) {
            if (broupDb != null) {
              if (chat.avatar != broupDb.avatar) {
                chat.avatar = broupDb.avatar;
                chat.avatarDefault = broupDb.avatarDefault;
              }
              for (int broId in chat.broIds) {
                Bro? dbBro = broMap[broId.toString()];
                if (dbBro != null) {
                  if (!chat.broupBros.any((element) => element.getId() == dbBro.getId())) {
                    chat.addBro(dbBro);
                  }
                }
              }
            }
            break;
          }
        }
      }
    });
  });
  return true;
}

Future<bool> getBros(Broup chat, Storage storage, Me me) async {
  // first check if one of the updateBros might not be needed to retrieve anymore, if he left for instance.
  for (int broToUpdateId in [...chat.updateBroIds]) {
    if (!chat.getBroIds().contains(broToUpdateId)) {
      // The broToUpdateId is no longer in the broIds, so we remove it.
      chat.updateBroIds.remove(broToUpdateId);
    }
  }
  for (int broAvatarToUpdateId in [...chat.updateBroAvatarIds]) {
    if (!chat.getBroIds().contains(broAvatarToUpdateId)) {
      chat.updateBroAvatarIds.remove(broAvatarToUpdateId);
    }
  }
  if (chat.updateBroIds.contains(me.getId())) {
    chat.updateBroIds.remove(me.getId());
  }
  if (chat.updateBroAvatarIds.contains(me.getId())) {
    chat.updateBroAvatarIds.remove(me.getId());
  }

  List<int> broIdsToRetrieveServer = [...chat.updateBroIds];
  List<int> broAvatarIdsToRetrieveServer = [...chat.updateBroAvatarIds];

  // Then retrieve from the server the bros that have to be updated.
  if (!chat.removed) {
    if (broIdsToRetrieveServer.isNotEmpty || broAvatarIdsToRetrieveServer.isNotEmpty) {
      // get bro details of a single broup
      AuthServiceSocial().broDetails(
          broIdsToRetrieveServer, broAvatarIdsToRetrieveServer, chat.broupId);
    }
  }

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
  List<Message> messagesServer = [];
  List<Message> messagesDB = [];

  // get messages from local db
  List<Message> localMessages = await storage.fetchMessages(chat.getBroupId(), 0);
  // Limit set to 50. If it retrieves less it means that it can't and all the messages have been retrieved.
  if (localMessages.length != 50) {
    allMessagesDBRetrieved = true;
  }
  if (localMessages.length != 0) {
    messagesDB = localMessages;
  }
  // get messages from the server
  if (!chat.removed) {
    if (chat.newMessages) {
      chat.newMessages = false;
      List<Message> retrievedMessages = await AuthServiceSocial()
          .retrieveMessages(chat.getBroupId(), chat.lastMessageId);

      if (retrievedMessages.isNotEmpty) {
        messagesServer = retrievedMessages;
        Message maxMessage = messagesServer.reduce((maxMessage, currentMessage) =>
        currentMessage.messageId > maxMessage.messageId ? currentMessage : maxMessage);

        chat.lastMessageId = maxMessage.messageId;
        // broup will be updated in the db later.
        chat.lastActivity = maxMessage.timestamp;
        await storage.updateBroup(chat);
      }
    }
  }

  List<Message> incomingMessages = messagesServer;
  Set<int> seenMessageServerIds = Set<int>.from(incomingMessages.map((e) => e.messageId));
  for (Message messageDB in messagesDB) {
    if (!seenMessageServerIds.contains(messageDB.messageId)) {
      incomingMessages.add(messageDB);
    }
  }
  mergeMessages(incomingMessages, chat);

  return allMessagesDBRetrieved;
}

Future<bool> fetchExtraMessages(int offSet, Broup chat, Storage storage) async {
  bool allMessagesDBRetrieved = false;
  List<Message> newMessages = await storage.fetchMessages(chat.getBroupId(), offSet);
  // Limit set to 50. If it retrieves less it means that it can't
  // and all the messages have been retrieved.
  if (newMessages.isEmpty) {
    return true;
  }
  if (newMessages.length != 50) {
    allMessagesDBRetrieved = true;
  }
  // We assume there are messages
  newMessages.sort((b, a) => a.getTimeStamp().compareTo(b.getTimeStamp()));
  // We will combine all the messages, the last message will probably be a date tile
  // We will check this and remove this because it will be reapplied later.
  if (chat.messages.isNotEmpty) {
    if (chat.messages.last.isInformation() && chat.messages.last.messageId == 0) {
      chat.messages.removeLast();
    }
  }
  removeDuplicates(newMessages, chat);
  chat.messages.addAll(newMessages);
  return allMessagesDBRetrieved;
}

mergeMessages(List<Message> incomingMessages, Broup chat) {
  List<Message> newMessages = removeDuplicates(incomingMessages, chat);
  if (chat.messages.isNotEmpty && newMessages.isNotEmpty) {
    int lastId = chat.messages.last.messageId;
    // the message Id's should be descending, so the first messageId is the highest
    int maxNewMessage = newMessages.fold(0, (max, message) =>
      message.messageId > max
      ? message.messageId
          : max);
    if (lastId < maxNewMessage) {
      // We assume that if the id is the same that it is the same message
      // And that it is correctly stored locally.
      // If we, for some reason, retrieve it again from the server we just ignore it.
      newMessages = newMessages.where((x) => x.messageId > lastId).toList();
    }
  }
  chat.messages.addAll(newMessages);
  chat.messages.sort((b, a) => a.getTimeStamp().compareTo(b.getTimeStamp()));
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

setDateTiles(Broup chat, int fromIndex) {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
  Message messageFirst = chat.messages[fromIndex];
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

  DateTime datetimeTimeMessage = DateTime(messageFirst.getTimeStamp().year,
      messageFirst.getTimeStamp().month, messageFirst.getTimeStamp().day);
  Message timeMessage = new Message(
    0,
    0,
    timeMessageFirst,
    "",
    datetimeTimeMessage.toUtc().toString(),
    null,
    true,
    chat.getBroupId(),
  );
  for (int i = fromIndex; i < chat.messages.length; i++) {
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

      chat.messages.insert(i, timeMessage);
      timeMessage = new Message(
        0,
        0,
        timeMessageTile,
        "",
        dayMessage.toUtc().toString(),
        null,
        true,
        chat.getBroupId(),
      );
    }
  }

  chat.messages.insert(chat.messages.length, timeMessage);
}
