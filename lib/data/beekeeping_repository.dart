import 'dart:io';

import 'package:apicultor/domain/beekeeping_models.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BeekeepingRepository {
  BeekeepingRepository._(this._database);

  final Database _database;

  static Future<BeekeepingRepository> open() async {
    if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final directory = await getApplicationSupportDirectory();
    final database = await openDatabase(
      path.join(directory.path, 'apicultor.sqlite'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE apiaries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE hives(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            apiary_id INTEGER NOT NULL REFERENCES apiaries(id),
            code TEXT NOT NULL,
            condition TEXT NOT NULL DEFAULT 'ii',
            queen_seen INTEGER NOT NULL DEFAULT 0,
            pending_tasks INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            UNIQUE(apiary_id, code)
          )
        ''');
        await db.execute('''
          CREATE TABLE inspections(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hive_id INTEGER NOT NULL REFERENCES hives(id),
            started_at TEXT NOT NULL,
            finished_at TEXT NOT NULL,
            condition TEXT NOT NULL,
            queen_seen INTEGER NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return BeekeepingRepository._(database);
  }

  static Future<BeekeepingRepository> openForTest(Database database) async {
    await database.execute('''
      CREATE TABLE apiaries(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, created_at TEXT NOT NULL)
    ''');
    await database.execute('''
      CREATE TABLE hives(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        apiary_id INTEGER NOT NULL,
        code TEXT NOT NULL,
        condition TEXT NOT NULL DEFAULT 'ii',
        queen_seen INTEGER NOT NULL DEFAULT 0,
        pending_tasks INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        UNIQUE(apiary_id, code)
      )
    ''');
    await database.execute('''
      CREATE TABLE inspections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hive_id INTEGER NOT NULL,
        started_at TEXT NOT NULL,
        finished_at TEXT NOT NULL,
        condition TEXT NOT NULL,
        queen_seen INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    return BeekeepingRepository._(database);
  }

  Future<List<Apiary>> listApiaries() async {
    final rows = await _database.query(
      'apiaries',
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Apiary.fromMap).toList();
  }

  Future<Apiary> createApiary(String name) async {
    final createdAt = DateTime.now().toUtc();
    final id = await _database.insert('apiaries', {
      'name': name.trim(),
      'created_at': createdAt.toIso8601String(),
    });
    return Apiary(id: id, name: name.trim(), createdAt: createdAt);
  }

  Future<List<Hive>> listHives(int apiaryId) async {
    final rows = await _database.query(
      'hives',
      where: 'apiary_id = ?',
      whereArgs: [apiaryId],
      orderBy: 'code COLLATE NOCASE',
    );
    return rows.map(Hive.fromMap).toList();
  }

  Future<Hive> createHive({required int apiaryId, required String code}) async {
    final id = await _database.insert('hives', {
      'apiary_id': apiaryId,
      'code': code.trim(),
      'condition': HiveCondition.ii.name,
      'queen_seen': 0,
      'pending_tasks': 0,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    return Hive(
      id: id,
      apiaryId: apiaryId,
      code: code.trim(),
      condition: HiveCondition.ii,
      queenSeen: false,
      pendingTasks: 0,
    );
  }

  Future<void> finishInspection({
    required Hive hive,
    required DateTime startedAt,
    required DateTime finishedAt,
  }) async {
    await _database.transaction((transaction) async {
      await transaction.insert('inspections', {
        'hive_id': hive.id,
        'started_at': startedAt.toUtc().toIso8601String(),
        'finished_at': finishedAt.toUtc().toIso8601String(),
        'condition': hive.condition.name,
        'queen_seen': hive.queenSeen ? 1 : 0,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    });
  }

  Future<void> close() => _database.close();
}
