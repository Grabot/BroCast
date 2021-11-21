import 'package:brocast/objects/bro_bros.dart';
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

  Storage._internal() {
    database;
  }

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
    await db.execute('''
    CREATE TABLE USER (
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

  Future<int> addUser(User user) async {
    Database database = await this.database;
    return database.insert(
      'User',
      user.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> selectUser() async {
    print("selecting user");
    Database database = await this.database;
    // We just expect there to be 1.
    String query = "SELECT * FROM User";
    print(query);
    List<Map<String, dynamic>> user = await database.rawQuery(query);
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

  // TODO: @Skools fix update and delete with id and broup boolean
  Future<int> updateChat(Chat chat) async {
    Database database = await this.database;
    return database.update(
      'Chat',
      chat.toDbMap(),
      where: 'chatId = ?',
      whereArgs: [chat.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteChat(int chatId, bool broup) async {
    Database database = await this.database;
    return database.delete(
      'Chat',
      where: 'chatId = ?',
      whereArgs: [chatId],
    );
  }
}