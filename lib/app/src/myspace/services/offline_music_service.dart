import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../model/offline_music.dart';
import 'package:logging/logging.dart';

class OfflineMusicService {
  static final OfflineMusicService instance = OfflineMusicService._internal();
  static final _logger = Logger('OfflineMusicService');

  Database? _database;

  OfflineMusicService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final pathToDb = path.join(dbPath, 'offline_music.db');

    return await openDatabase(
      pathToDb,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_music(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            artist TEXT NOT NULL,
            filePath TEXT NOT NULL,
            duration TEXT NOT NULL,
            downloadDate TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveMusic(OfflineMusic music) async {
    try {
      final db = await database;
      await db.insert(
        'offline_music',
        music.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.info('Saved music metadata: ${music.title}');
    } catch (e, stack) {
      _logger.severe('Error saving music metadata', e, stack);
      rethrow;
    }
  }

  Future<List<OfflineMusic>> getAllMusic() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('offline_music');
      return List.generate(maps.length, (i) => OfflineMusic.fromMap(maps[i]));
    } catch (e, stack) {
      _logger.severe('Error fetching music list', e, stack);
      rethrow;
    }
  }

  Future<void> deleteMusic(String id) async {
    try {
      final db = await database;
      // First get the file path
      final List<Map<String, dynamic>> result = await db.query(
        'offline_music',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final filePath = result.first['filePath'] as String;
        // Delete the file
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }

        // Delete the database entry
        await db.delete(
          'offline_music',
          where: 'id = ?',
          whereArgs: [id],
        );
        _logger.info('Deleted music with ID: $id');
      }
    } catch (e, stack) {
      _logger.severe('Error deleting music', e, stack);
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      _database = null;
      _logger.info('Database connection closed');
    } catch (e, stack) {
      _logger.severe('Error closing database', e, stack);
      rethrow;
    }
  }
}
