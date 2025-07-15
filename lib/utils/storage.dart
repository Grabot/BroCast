import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/message.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../objects/bro.dart';


class Storage {
  static const _dbName = "brocast_v16.db";

  static final Storage _instance = Storage._internal();

  var based;

  factory Storage() {
    return _instance;
  }

  Storage._internal();

  Future<Database> get database async {
    if (based != null) return based;
    based = await _initDatabase();
    return based;
  }

  // Creates and opens the database.
  _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version,) async {
    await createTableBroup(db);
    await createTableMessage(db);
    await createTableBro(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion,) async {
    if (oldVersion == 1 && newVersion >= 2) {
      db.execute('ALTER TABLE Broup ADD lastMessageReadId INTEGER DEFAULT 0');
    }
    if ((oldVersion == 1 || oldVersion == 2) && newVersion >= 3) {
      List<Map<String, dynamic>> maps = await db.query(
        'Message',
      );
      List<Map<String, dynamic>> newMessageMaps = [];
      if (maps.isNotEmpty) {
        for (Map<String, dynamic> messageMap in maps) {
          Map<String, dynamic> newMap = Map<String, dynamic>.from(messageMap);
          // In this version we had string as data representation and we want to switch to Uint8List
          String? data = newMap['data'];
          // It will later change again, but to upgrade to v14 we will first go to bytes
          if (data != null) {
            Uint8List newData = base64.decode(data);
            newMap['data'] = newData;
          }
          newMessageMaps.add(newMap);
        }
      }
      // To change the type of the data on the message table
      // we have to drop the old one and recreate it.
      await db.execute('DROP TABLE Message');
      // Recreate the message table, so we also add the new `emojiReactions` column.
      await createTableMessage(db);
      if (newMessageMaps.isNotEmpty) {
        //  Insert the data from the old table into the new table
        for (Map<String, dynamic> message in newMessageMaps) {
          await db.insert('Message', message);
        }
      }
      db.execute('ALTER TABLE Broup ADD localLastMessageReadId INTEGER DEFAULT 0');
    }
    if ((oldVersion == 1 || oldVersion == 2 || oldVersion == 3) && newVersion >= 4) {
      String query = "SELECT messageId, broupId FROM Message";
      List<Map<String, dynamic>> maps = await db.rawQuery(query);
      List<List<int>> messageIdGroups = [];
      List<Map<String, dynamic>> newMessageMaps = [];
      if (maps.isNotEmpty) {
        messageIdGroups = maps
            .map((map) => [map['messageId'] as int, map['broupId'] as int])
            .toList();
        for (List<int> messageIdGroup in messageIdGroups) {
          int messageId = messageIdGroup[0];
          int broupId = messageIdGroup[1];
          // We retrieve each message separately because we found an issue with a database query limit.
          String query = "SELECT * FROM Message WHERE messageId = $messageId AND broupId = $broupId";

          List<Map<String, dynamic>> messageMap = await db.rawQuery(query);
          // We do these message by message, so the list will be of length 1.
          if (messageMap.isNotEmpty && messageMap.length == 1) {
            // The messageMap is almost correct, but the data is not in the right format.
            // It is a Uint8List now but we want it to be a path location.
            Map<String, dynamic> newMap = Map<String, dynamic>.from(messageMap[0]);
            Uint8List? data = newMap['data'];
            if (data != null) {
              String path = await saveImageData(data);
              newMap['data'] = path;
            }
            newMap['dataIsReceived'] = 1;
            newMessageMaps.add(newMap);
          }
        }
      }
      // To change the type of the data on the message table
      // we have to drop the old one and recreate it.
      await db.execute('DROP TABLE Message');
      // Recreate the message table, so we also add the new `emojiReactions` column.
      // This will also add the new `dataIsReceived` column
      await createTableMessage(db);
      if (newMessageMaps.isNotEmpty) {
        //  Insert the data from the old table into the new table
        for (Map<String, dynamic> message in newMessageMaps) {
          await db.insert('Message', message);
        }
      }
    }
  }

  createTableBroup(Database db) async {
    // Save all the broup information in the database
    // The messages will be a list with message ids
    await db.execute('''
          CREATE TABLE Broup (
            id INTEGER PRIMARY KEY,
            broupId INTEGER,
            broIds TEXT,
            adminIds TEXT,
            updateBroIds TEXT,
            updateBroAvatarIds TEXT,
            broupName TEXT NOT NULL,
            broupDescription TEXT,
            alias TEXT,
            broupColour TEXT,
            unreadMessages INTEGER,
            private INTEGER,
            mute INTEGER,
            muteValue TEXT,
            deleted INTEGER,
            removed INTEGER,
            blocked INTEGER,
            lastMessageId INTEGER,
            brosUpdate TEXT,
            avatar BLOB,
            avatarDefault INTEGER,
            messages TEXT,
            lastActivity TEXT,
            lastMessageReadId INTEGER,
            localLastMessageReadId INTEGER,
            UNIQUE(broupId) ON CONFLICT REPLACE
          );
          ''');
  }

  createTableMessage(Database db) async {
    await db.execute('''
          CREATE TABLE Message (
            id INTEGER PRIMARY KEY,
            messageId INTEGER,
            senderId INTEGER,
            broupId INTEGER,
            body TEXT,
            textMessage TEXT,
            info INTEGER,
            timestamp TEXT,
            isRead INTEGER,
            data TEXT,
            dataType INTEGER,
            dataIsReceived INTEGER,
            repliedTo INTEGER,
            emojiReactions TEXT,
            UNIQUE(messageId, broupId, info) ON CONFLICT REPLACE
          );
          ''');
  }

  createTableBro(Database db) async {
    await db.execute('''
          CREATE TABLE Bro (
            id INTEGER PRIMARY KEY,
            broId INTEGER,
            broName TEXT,
            bromotion TEXT,
            avatar BLOB,
            UNIQUE(broId) ON CONFLICT REPLACE
          );
          ''');
  }

  Future<int> addBro(Bro bro) async {
    Database database = await this.database;
    return database.insert(
      'Bro',
      bro.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateBro(Bro bro) async {
    Database database = await this.database;
    return database.update(
      'Bro',
      bro.toDbMap(),
      where: 'broId = ?',
      whereArgs: [bro.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Bro>> fetchAllBros() async {
    Database database = await this.database;
    List<Map<String, dynamic>> maps = await database.query('Bro');
    if (maps.isNotEmpty) {
      return maps
          .map((map) => Bro.fromDbMap(map))
          .toList();
    }
    return List.empty();
  }

  Future<int> addBroup(Broup broup) async {
    Database database = await this.database;
    return database.insert(
      'Broup',
      broup.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateBroup(Broup broup) async {
    Database database = await this.database;
    return database.update(
      'Broup',
      broup.toDbMap(),
      where: 'broupId = ?',
      whereArgs: [broup.broupId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Broup>> fetchAllBroups() async {
    Database database = await this.database;
    List<Map<String, dynamic>> maps = await database.query(
      'Broup',
      where: 'deleted = 0',
    );
    if (maps.isNotEmpty) {
      return maps
          .map((map) => Broup.fromDbMap(map))
          .toList();
    }
    return List.empty();
  }

  Future<int> addMessage(Message message) async {
    Database database = await this.database;
    return database.insert(
      'Message',
      message.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateMessage(Message message) async {
    Database database = await this.database;
    return database.update(
      'Message',
      message.toDbMap(),
      where: 'messageId = ? and broupId = ?',
      whereArgs: [message.messageId, message.broupId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteChat(int broupId) async {
    Database database = await this.database;
    return database.delete(
      'Broup',
      where: 'broupId = ?',
      whereArgs: [broupId],
    );
  }

  Future<int> deleteChatMessages(int broupId) async {
    Database database = await this.database;

    // We will first go over all the messages and remove any data attached to them.
    String query = "SELECT messageId, broupId FROM Message where broupId = $broupId";
    List<Map<String, dynamic>> maps = await database.rawQuery(query);
    List<List<int>> messageIdGroups = [];
    if (maps.isNotEmpty) {
      messageIdGroups = maps
          .map((map) => [map['messageId'] as int, map['broupId'] as int])
          .toList();
      for (List<int> messageIdGroup in messageIdGroups) {
        int messageId = messageIdGroup[0];
        int broupId = messageIdGroup[1];
        String query = "SELECT * FROM Message WHERE messageId = $messageId AND broupId = $broupId";

        List<Map<String, dynamic>> messageMap = await database.rawQuery(query);
        // We do these message by message, so the list will be of length 1.
        if (messageMap.isNotEmpty && messageMap.length == 1) {
          String? dataPath = messageMap[0]['data'];
          // remove the file if it exists
          if (dataPath != null) {
            File file = File(dataPath);
            if (await file.exists()) {
              await file.delete();
            }
          }
        }
      }
    }

    return database.delete(
      'Message',
      where: 'broupId = ?',
      whereArgs: [broupId],
    );
  }

  Future<List<Message>> fetchMessages(
      int broupId, int offSet) async {
    int limit = 50;
    int setOff = limit * offSet;
    Database database = await this.database;
    String query = "SELECT * FROM Message where"
            " broupId = " +
        broupId.toString() +
        " order by messageId desc " +
        " limit " +
        limit.toString() +
        " offset " +
        setOff.toString();
    List<Map<String, dynamic>> maps = await database.rawQuery(query);
    if (maps.isNotEmpty) {
      return maps.map((map) => Message.fromDbMap(map)).toList();
    }
    return List.empty();
  }

  Future<List<Message>> retrieveMessages(List<int> retrieveMessagesIds) async {
    Database database = await this.database;
    String query = "SELECT * FROM Message WHERE messageId IN (${retrieveMessagesIds.join(',')})";
    List<Map<String, dynamic>> maps = await database.rawQuery(query);
    if (maps.isNotEmpty) {
      return maps.map((map) => Message.fromDbMap(map)).toList();
    }
    return List.empty();
  }

  Future<List<Bro>> fetchBros(List<int> broIds) async {
    Database database = await this.database;
    String query = "SELECT * FROM Bro WHERE broId IN (${broIds.join(',')})";
    List<Map<String, dynamic>> maps = await database.rawQuery(query);
    if (maps.isNotEmpty) {
      return maps.map((map) => Bro.fromDbMap(map)).toList();
    }
    return List.empty();
  }

  Future<Bro?> fetchBro(int broId) async {
    Database database = await this.database;
    List<Map<String, dynamic>> maps = await database.query(
      'Bro',
      where: 'broId = ?',
      whereArgs: [broId],
    );
    if (maps.isNotEmpty) {
      return Bro.fromDbMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Broup>> fetchBroups(List<int> broupIds) async {
    Database database = await this.database;
    String query = "SELECT * FROM Broup WHERE broupId IN (${broupIds.join(',')})";
    List<Map<String, dynamic>> maps = await database.rawQuery(query);
    if (maps.isNotEmpty) {
      return maps.map((map) => Broup.fromDbMap(map)).toList();
    }
    return List.empty();
  }

  Future<Broup?> fetchBroup(int broupId) async {
    Database database = await this.database;
    List<Map<String, dynamic>> maps = await database.query(
      'Broup',
      where: 'broupId = ?',
      whereArgs: [broupId],
    );
    if (maps.isNotEmpty) {
      return Broup.fromDbMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Message?> fetchMessage(int broupId, int messageId) async {
    Database database = await this.database;
    List<Map<String, dynamic>> maps = await database.query(
      'Message',
      where: 'messageId = ? and broupId = ?',
      whereArgs: [messageId, broupId],
    );
    if (maps.isNotEmpty) {
      return Message.fromDbMap(maps.first);
    } else {
      return null;
    }
  }

  clearDatabase() async {
    Database database = await this.database;
    await database.execute("DROP TABLE IF EXISTS Bro");
    await database.execute("DROP TABLE IF EXISTS Broup");

    // We will first go over all the messages and remove any data attached to them.
    String query = "SELECT messageId, broupId FROM Message";
    List<Map<String, dynamic>> maps = await database.rawQuery(query);
    List<List<int>> messageIdGroups = [];
    if (maps.isNotEmpty) {
      messageIdGroups = maps
          .map((map) => [map['messageId'] as int, map['broupId'] as int])
          .toList();
      for (List<int> messageIdGroup in messageIdGroups) {
        int messageId = messageIdGroup[0];
        int broupId = messageIdGroup[1];
        String query = "SELECT * FROM Message WHERE messageId = $messageId AND broupId = $broupId";

        List<Map<String, dynamic>> messageMap = await database.rawQuery(query);
        // We do these message by message, so the list will be of length 1.
        if (messageMap.isNotEmpty && messageMap.length == 1) {
          String? dataPath = messageMap[0]['data'];
          // remove the file if it exists
          if (dataPath != null) {
            File file = File(dataPath);
            if (await file.exists()) {
              await file.delete();
              print("Deleted file at $dataPath");
            }
          }
        }
      }
    }

    await database.execute("DROP TABLE IF EXISTS Message");
    await createTableBroup(database);
    await createTableBro(database);
    await createTableMessage(database);
  }

  clearMessages() async {
    Database database = await this.database;

    // We will first go over all the messages and remove any data attached to them.
    String query = "SELECT messageId, broupId FROM Message";
    List<Map<String, dynamic>> maps = await database.rawQuery(query);
    List<List<int>> messageIdGroups = [];
    if (maps.isNotEmpty) {
      messageIdGroups = maps
          .map((map) => [map['messageId'] as int, map['broupId'] as int])
          .toList();
      for (List<int> messageIdGroup in messageIdGroups) {
        int messageId = messageIdGroup[0];
        int broupId = messageIdGroup[1];
        String query = "SELECT * FROM Message WHERE messageId = $messageId AND broupId = $broupId";

        List<Map<String, dynamic>> messageMap = await database.rawQuery(query);
        // We do these message by message, so the list will be of length 1.
        if (messageMap.isNotEmpty && messageMap.length == 1) {
          String? dataPath = messageMap[0]['data'];
          // remove the file if it exists
          if (dataPath != null) {
            File file = File(dataPath);
            if (await file.exists()) {
              await file.delete();
              print("Deleted file at $dataPath");
            }
          }
        }
      }
    }

    await database.execute("DROP TABLE IF EXISTS Message");
    await createTableMessage(database);
  }
}
