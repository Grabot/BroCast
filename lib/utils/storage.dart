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
      version: 3,
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
      List<Message> messages = [];
      if (maps.isNotEmpty) {
        messages = maps
            .map((map) => Message.fromDbMapV14(map))
            .toList();
      }
      if (messages.isNotEmpty) {
        messages.sort((a, b) => a.messageId.compareTo(b.messageId));
      }
      // To change the type of the data on the message table
      // we have to drop the old one and recreate it.
      await db.execute('DROP TABLE Message');
      await createTableMessage(db);

      //  Insert the data from the old table into the new table
      for (Message message in messages) {
        await db.insert('Message', message.toDbMap());
      }
      db.execute('ALTER TABLE Broup ADD localLastMessageReadId INTEGER DEFAULT 0');
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
            data BLOB,
            dataType INTEGER,
            repliedTo INTEGER,
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

  clearDatabase() async {
    Database database = await this.database;
    await database.execute("DROP TABLE IF EXISTS Bro");
    await database.execute("DROP TABLE IF EXISTS Broup");
    await database.execute("DROP TABLE IF EXISTS Message");
    await createTableBroup(database);
    await createTableBro(database);
    await createTableMessage(database);
  }

  clearMessages() async {
    Database database = await this.database;
    await database.execute("DROP TABLE IF EXISTS Message");
    await createTableMessage(database);
  }
}
