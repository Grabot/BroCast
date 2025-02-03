import 'package:brocast/objects/bro_bros.dart';
// import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/objects/message.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Storage {
  static const _dbName = "brocast.db";

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
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Creates the database structure (unless database has already been created)
  Future _onCreate(
    Database db,
    int version,
  ) async {
    await createTableChat(db);
    await createTableBro(db);
    await createTableMessage(db);
  }

  createTableChat(Database db) async {
    await db.execute('''
          CREATE TABLE Chat (
            id INTEGER PRIMARY KEY,
            chatId INTEGER,
            lastActivity TEXT,
            chatName TEXT NOT NULL,
            chatDescription TEXT,
            alias TEXT,
            chatColor TEXT,
            roomName TEXT,
            unreadMessages INTEGER,
            blocked INTEGER,
            mute INTEGER,
            left INTEGER,
            isBroup INTEGER,
            participants TEXT,
            admins TEXT,
            UNIQUE(chatId, isBroup) ON CONFLICT REPLACE
          );
          ''');
  }

  createTableBro(Database db) async {
    await db.execute('''
          CREATE TABLE Bro (
            id INTEGER PRIMARY KEY,
            broId INTEGER,
            broupId INTEGER,
            admin INTEGER,
            added INTEGER,
            chatName TEXT,
            broName TEXT,
            bromotion TEXT,
            UNIQUE(broId, broupId) ON CONFLICT REPLACE
          );
          ''');
  }

  createTableMessage(Database db) async {
    await db.execute('''
          CREATE TABLE Message (
            id INTEGER PRIMARY KEY,
            messageId INTEGER,
            senderId INTEGER,
            recipientId INTEGER,
            chatId INTEGER,
            body TEXT,
            textMessage TEXT,
            info INTEGER,
            timestamp TEXT,
            data TEXT,
            isRead INTEGER,
            isBroup INTEGER,
            UNIQUE(messageId, chatId, isBroup) ON CONFLICT REPLACE
          );
          ''');
  }

  // Future<int> addBro(Bro bro) async {
  //   Database database = await this.database;
  //   return database.insert(
  //     'Bro',
  //     bro.toDbMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }
  //
  // Future<Bro?> selectBro(String broId, String broupId) async {
  //   Database database = await this.database;
  //   String query = "SELECT * FROM Bro where broId = " +
  //       broId +
  //       " and broupId = " +
  //       broupId;
  //   List<Map<String, dynamic>> bro = await database.rawQuery(query);
  //   if (bro.length != 1) {
  //     return null;
  //   } else {
  //     if (bro[0]["added"] == 1) {
  //       return BroAdded.fromDbMap(bro[0]);
  //     } else {
  //       return BroNotAdded.fromDbMap(bro[0]);
  //     }
  //   }
  // }
  //
  // Future<List<Bro>> fetchAllBrosOfBroup(String broupId) async {
  //   Database database = await this.database;
  //   String query = "SELECT * FROM Bro where broupId = " + broupId;
  //   List<Map<String, dynamic>> bros = await database.rawQuery(query);
  //   if (bros.isNotEmpty) {
  //     return bros
  //         .map((map) => map['added'] == 1
  //             ? BroAdded.fromDbMap(map)
  //             : BroNotAdded.fromDbMap(map))
  //         .toList();
  //   }
  //   return List.empty();
  // }
  //
  // Future<int> updateBro(Bro bro, String broupId) async {
  //   Database database = await this.database;
  //   return database.update(
  //     'Bro',
  //     bro.toDbMap(),
  //     where: 'broId = ? and broupId = ?',
  //     whereArgs: [bro.id, broupId],
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  Future<int> deleteBro(String broId, String broupId) async {
    Database database = await this.database;
    return database.delete(
      'Bro',
      where: 'broId = ? and broupId = ?',
      whereArgs: [broId, broupId],
    );
  }

  // Future<int> addUser(User user) async {
  //   Database database = await this.database;
  //   return database.insert(
  //     'User',
  //     user.toDbMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // Future<User?> selectUser() async {
  //   Database database = await this.database;
  //   String query = "SELECT * FROM User";
  //   List<Map<String, dynamic>> user = await database.rawQuery(query);
  //   if (user.length != 1) {
  //     return null;
  //   } else {
  //     return User.fromDbMap(user[0]);
  //   }
  // }
  //
  // Future<int> updateUser(User user) async {
  //   Database database = await this.database;
  //   return database.update(
  //     'User',
  //     user.toDbMap(),
  //     where: 'id = ?',
  //     whereArgs: [user.id],
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  Future<int> addChat(Chat chat) async {
    Database database = await this.database;
    return database.insert(
      'Chat',
      chat.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Future<List<Chat>> fetchAllChats() async {
  //   Database database = await this.database;
  //   List<Map<String, dynamic>> maps = await database.query('Chat');
  //   if (maps.isNotEmpty) {
  //     return maps
  //         .map((map) => map['isBroup'] == 1
  //             ? Broup.fromDbMap(map)
  //             : BroBros.fromDbMap(map))
  //         .toList();
  //   }
  //   return List.empty();
  // }
  //
  // Future<Chat?> selectChat(String chatId, String isBroup) async {
  //   Database database = await this.database;
  //   String query = "SELECT * FROM Chat where chatId = " +
  //       chatId +
  //       " and isBroup = " +
  //       isBroup;
  //   List<Map<String, dynamic>> chat = await database.rawQuery(query);
  //   if (chat.length != 1) {
  //     return null;
  //   } else {
  //     if (chat[0]["isBroup"] == 1) {
  //       return Broup.fromDbMap(chat[0]);
  //     } else {
  //       return BroBros.fromDbMap(chat[0]);
  //     }
  //   }
  // }

  Future<int> updateChat(Chat chat) async {
    Database database = await this.database;
    return database.update(
      'Chat',
      chat.toDbMap(),
      where: 'chatId = ? and isBroup = ?',
      whereArgs: [chat.id, chat.broup],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteChat(Chat chat) async {
    Database database = await this.database;
    return database.delete(
      'Chat',
      where: 'chatId = ? and isBroup = ?',
      whereArgs: [chat.id, chat.broup],
    );
  }

  Future<int> addMessage(Message message) async {
    Database database = await this.database;
    return database.insert(
      'Message',
      message.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Message>> fetchEverything() async {
    Database database = await this.database;
    // select * from TABLE_NAME limit 1 offset 2
    String query = "SELECT * FROM Message";
    List<Map<String, dynamic>> maps = await database.rawQuery(query);
    if (maps.isNotEmpty) {
      return maps.map((map) => Message.fromDbMap(map)).toList();
    }
    return List.empty();
  }

  Future<List<Message>> fetchAllMessages(
      int chatId, int isBroup, int offSet) async {
    int limit = 50;
    int setOff = limit * offSet;
    Database database = await this.database;
    String query = "SELECT * FROM Message where"
            " chatId = " +
        chatId.toString() +
        " and"
            " isBroup = " +
        isBroup.toString() +
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

  Future<Message?> selectMessage(int messageId, int isBroup) async {
    Database database = await this.database;
    String query = "SELECT * FROM Message where messageId = " +
        messageId.toString() +
        " isBroup = " +
        isBroup.toString();
    List<Map<String, dynamic>> message = await database.rawQuery(query);
    if (message.length != 1) {
      return null;
    } else {
      return Message.fromDbMap(message[0]);
    }
  }

  clearChatTable() async {
    Database database = await this.database;
    await database.execute("DROP TABLE IF EXISTS Chat");
    await database.execute("DROP TABLE IF EXISTS Bro");
    await createTableChat(database);
    await createTableBro(database);
  }

  clearDatabase() async {
    Database database = await this.database;
    await database.execute("DROP TABLE IF EXISTS Chat");
    await database.execute("DROP TABLE IF EXISTS User");
    await database.execute("DROP TABLE IF EXISTS Bro");
    await database.execute("DROP TABLE IF EXISTS Message");
    await createTableChat(database);
    await createTableBro(database);
    await createTableMessage(database);
  }

  clearMessages() async {
    Database database = await this.database;
    await database.execute("DROP TABLE IF EXISTS Message");
    await createTableMessage(database);
  }
}
