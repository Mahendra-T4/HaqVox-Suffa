import 'package:haqvox/app/core/database/hive_database.dart';
import 'package:haqvox/app/core/database/hive_models/recent_play_model.dart';

/// Recent Play Repository - Handles all recent play-related database operations
class RecentPlayRepository {
  final HiveDatabase _hiveDatabase = HiveDatabase();

  /// Get all recent plays ordered by date (newest first)
  Future<List<RecentPlayModel>> getAllRecentPlays() async {
    try {
      final plays = _hiveDatabase.recentPlayBox.values.toList();
      plays.sort((a, b) => b.playDate.compareTo(a.playDate));
      return plays;
    } catch (e) {
      print('Error getting all recent plays: $e');
      return [];
    }
  }

  /// Get limited recent plays
  Future<List<RecentPlayModel>> getLimitedRecentPlays(int limit) async {
    try {
      final plays = await getAllRecentPlays();
      return plays.take(limit).toList();
    } catch (e) {
      print('Error getting limited recent plays: $e');
      return [];
    }
  }

  /// Get recent plays by ebook slug
  Future<List<RecentPlayModel>> getRecentPlaysByEbook(String ebookSlug) async {
    try {
      final plays = _hiveDatabase.recentPlayBox.values
          .where((play) => play.ebookSlug == ebookSlug)
          .toList();
      plays.sort((a, b) => b.playDate.compareTo(a.playDate));
      return plays;
    } catch (e) {
      print('Error getting recent plays by ebook: $e');
      return [];
    }
  }

  /// Get recent plays by chapter slug
  Future<List<RecentPlayModel>> getRecentPlaysByChapter(
    String chapterSlug,
  ) async {
    try {
      final plays = _hiveDatabase.recentPlayBox.values
          .where((play) => play.chapterSlug == chapterSlug)
          .toList();
      plays.sort((a, b) => b.playDate.compareTo(a.playDate));
      return plays;
    } catch (e) {
      print('Error getting recent plays by chapter: $e');
      return [];
    }
  }

  /// Add or update recent play
  Future<void> addOrUpdateRecentPlay(RecentPlayModel play) async {
    try {
      // Check if already exists
      final existing = _hiveDatabase.recentPlayBox.values
          .where((p) => p.audioSlug == play.audioSlug)
          .toList();

      if (existing.isNotEmpty) {
        // Update existing - create new instance with updated values
        await _hiveDatabase.recentPlayBox.put(existing.first.key, play);
      } else {
        // Insert new
        await _hiveDatabase.recentPlayBox.add(play);
      }
    } catch (e) {
      print('Error adding/updating recent play: $e');
      rethrow;
    }
  }

  /// Delete recent play by audio slug
  Future<void> deleteRecentPlayByAudioSlug(String audioSlug) async {
    try {
      final plays = _hiveDatabase.recentPlayBox.values
          .where((p) => p.audioSlug == audioSlug)
          .toList();

      for (final play in plays) {
        await play.delete();
      }
    } catch (e) {
      print('Error deleting recent play: $e');
      rethrow;
    }
  }

  /// Delete recent play by key
  Future<void> deleteRecentPlayByKey(dynamic key) async {
    try {
      await _hiveDatabase.recentPlayBox.delete(key);
    } catch (e) {
      print('Error deleting recent play by key: $e');
      rethrow;
    }
  }

  /// Clear all recent plays
  Future<void> clearAllRecentPlays() async {
    try {
      await _hiveDatabase.recentPlayBox.clear();
    } catch (e) {
      print('Error clearing all recent plays: $e');
      rethrow;
    }
  }

  /// Get recent plays count
  Future<int> getRecentPlaysCount() async {
    try {
      return _hiveDatabase.recentPlayBox.length;
    } catch (e) {
      return 0;
    }
  }

  /// Watch recent plays (stream)
  Stream<List<RecentPlayModel>> watchRecentPlays() async* {
    try {
      yield await getAllRecentPlays();
      await for (final _ in _hiveDatabase.recentPlayBox.watch()) {
        yield await getAllRecentPlays();
      }
    } catch (e) {
      print('Error watching recent plays: $e');
      yield [];
    }
  }
}
