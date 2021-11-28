import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/bro_not_added.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/objects/user.dart';
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
    print("initializing the database");
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
    print("executing query");
    await createTableUser(db);
    await createTableChat(db);
    await createTableBro(db);
  }

  createTableUser(Database db) async {
    print("create table user");
    await db.execute('''
    CREATE TABLE User (
            id INTEGER PRIMARY KEY,
            broName TEXT,
            bromotion TEXT,
            password TEXT,
            token TEXT,
            registrationId TEXT,
            recheckBros INTEGER,
            keyboardDarkMode INTEGER
          );
          ''');
  }

  createTableChat(Database db) async {
    print("create table chat");
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
            isBroup INTEGER,
            participants TEXT,
            admins TEXT,
            UNIQUE(chatId, isBroup) ON CONFLICT REPLACE
          );
          ''');
  }

  createTableBro(Database db) async {
    print("create table bro");
    await db.execute('''
          CREATE TABLE Bro (
            id INTEGER PRIMARY KEY,
            broId INTEGER,
            broupId INTEGER,
            admin INTEGER,
            added INTEGER,
            chatName TEXT,
            broName TEXT,
            bromotion TEXT
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

  Future<Bro?> selectBro(int broId, int broupId) async {
    print("selecting bro");
    Database database = await this.database;
    String query = "SELECT * FROM Bro where broId = " + broId.toString() + " and broupId = " + broupId.toString();
    print(query);
    List<Map<String, dynamic>> bro = await database.rawQuery(query);
    print(bro);
    if (bro.length != 1) {
      return null;
    } else {
      if (bro[0]["added"] == 1) {
        return BroAdded.fromDbMap(bro[0]);
      } else {
        return BroNotAdded.fromDbMap(bro[0]);
      }
    }
  }

  Future<int> updateBro(Bro bro) async {
    Database database = await this.database;
    return database.update(
      'Bro',
      bro.toDbMap(),
      where: 'broId = ? and broupId = ?',
      whereArgs: [bro.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> addUser(User user) async {
    Database database = await this.database;
    return database.insert(
      'User',
      user.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> selectUser() async {
    Database database = await this.database;
    String query = "SELECT * FROM User";
    List<Map<String, dynamic>> user = await database.rawQuery(query);
    print("user!");
    print(user);
    if (user.length != 1) {
      return null;
    } else {
      return User.fromDbMap(user[0]);
    }
  }

  Future<int> updateUser(User user) async {
    Database database = await this.database;
    return database.update(
      'User',
      user.toDbMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> addChat(Chat chat) async {
    Database database = await this.database;
    return database.insert(
      'Chat',
      chat.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Chat>> fetchAllChats() async {
    Database database = await this.database;
    List<Map<String, dynamic>> maps = await database.query('Chat');
    if (maps.isNotEmpty) {
      return maps.map((map) =>
      map['isBroup'] == 1
          ? Broup.fromDbMap(map)
          : BroBros.fromDbMap(map)
      ).toList();
    }
    return List.empty();
  }

  Future<Chat?> selectChat(int chatId, int isBroup) async {
    print("selecting chat");
    Database database = await this.database;
    String query = "SELECT * FROM Chat where chatId = " + chatId.toString() + " and isBroup = " + isBroup.toString();
    print(query);
    List<Map<String, dynamic>> chat = await database.rawQuery(query);
    print(chat);
    if (chat.length != 1) {
      return null;
    } else {
      if (chat[0]["isBroup"] == 1) {
        return Broup.fromDbMap(chat[0]);
      } else {
        return BroBros.fromDbMap(chat[0]);
      }
    }
  }

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
    await createTableUser(database);
    await createTableChat(database);
    await createTableBro(database);
  }
}