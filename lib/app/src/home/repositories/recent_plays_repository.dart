// DEPRECATED: This file is deprecated and replaced with lib/app/core/database/repositories/recent_play_repository.dart
// which uses Hive instead of Drift for database operations.
//
// import 'package:haqvox/app/core/database/app_database.dart';
//
// class RecentPlaysRepository {
//   final AppDatabase _database;
//   static final RecentPlaysRepository _instance =
//       RecentPlaysRepository._internal();
//
//   factory RecentPlaysRepository() {
//     return _instance;
//   }
//
//   RecentPlaysRepository._internal() : _database = AppDatabase();
//
//   Future<List<RecentPlay>> getAllRecentPlays() {
//     return _database.getAllRecentPlays();
//   }
//
//   Future<List<RecentPlay>> getLimitedRecentPlays(int limit) {
//     return _database.getLimitedRecentPlays(limit);
//   }
//
//   Future<int> addOrUpdateRecentPlay({
//     required String audioName,
//     required String audioPath,
//     required String chapterSlug,
//     required String ebookSlug,
//     required String audioSlug,
//     String? thumbnailUrl,
//     int? duration,
//     int? position,
//   }) {
//     final entry = RecentPlaysCompanion(
//       audioName: Value(audioName),
//       audioPath: Value(audioPath),
//       chapterSlug: Value(chapterSlug),
//       ebookSlug: Value(ebookSlug),
//       audioSlug: Value(audioSlug),
//       playDate: Value(DateTime.now().toIso8601String()),
//       thumbnailUrl: Value(thumbnailUrl),
//       duration: Value(duration),
//       position: Value(position),
//     );
//     return _database.addOrUpdateRecentPlay(entry);
//   }
//
//   Future<int> deleteRecentPlay(String audioSlug) {
//     return _database.deleteRecentPlay(audioSlug);
//   }
//
//   Future<int> clearRecentPlays() {
//     return _database.clearRecentPlays();
//   }
//
//   void dispose() {
//     _database.close();
//   }
// }
