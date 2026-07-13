import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'dart:async';
import '../models/recent_play_model.dart';
import 'package:path_provider/path_provider.dart';

class RecentPlaysService {
  static const String _boxName = 'recentPlays';
  final _logger = Logger('RecentPlaysService');
  static const int _maxRecentPlays = 20;
  Box<RecentPlay>? _box;
  final _recentPlaysController = StreamController<List<RecentPlay>>.broadcast();
  StreamSubscription? _boxSubscription;

  Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(RecentPlayAdapter());
      }
      final dir = await getApplicationDocumentsDirectory();
      print('[RecentPlaysService] App doc dir: ' + dir.path);
      _box = await Hive.openBox<RecentPlay>(_boxName);
      print('[RecentPlaysService] Hive box path: ' + (_box!.path ?? 'unknown'));
      final initialList = getRecentPlays();
      _logger.info(
        'RecentPlaysService initialized. Box contains: \\n' +
            initialList.map((e) => e.title).join(', '),
      );
      _recentPlaysController.add(initialList);

      // Listen to box changes using addListener
      final listenable = _box?.listenable();
      if (listenable != null) {
        listenable.addListener(() {
          final plays = getRecentPlays();
          _logger.info(
            'Box changed. Now contains: ' +
                plays.map((e) => e.title).join(', '),
          );
          _recentPlaysController.add(plays);
        });
      }

      _logger.info('RecentPlaysService initialized successfully');
    } catch (e, stack) {
      _logger.severe('Error initializing RecentPlaysService', e, stack);
      _recentPlaysController.addError(e);
    }
  }

  Stream<List<RecentPlay>> watchRecentPlays() {
    if (_box == null) {
      return Stream.error('RecentPlaysService not initialized');
    }
    return _recentPlaysController.stream;
  }

  Future<void> addToRecent(MediaItem mediaItem) async {
    try {
      if (_box == null) {
        _logger.warning('Hive box not initialized');
        return;
      }

      final url = mediaItem.extras?['url'] as String? ?? mediaItem.id;
      _logger.info('Adding to recent plays: ${mediaItem.title} (URL: $url)');

      // Create new recent play
      final recentPlay = RecentPlay.fromMediaItem(mediaItem);

      // Find existing entry
      var existingEntries = _box!.values.toList();
      var existingIndex = existingEntries.indexWhere(
        (item) => item.audioUrl == url,
      );

      // If exists, update position
      if (existingIndex != -1) {
        await _box!.deleteAt(existingIndex);
      }

      // Add new entry
      await _box!.add(recentPlay);
      await _box!.flush();
      _logger.info('Added recent play: ${recentPlay.title}');
      _logger.info(
        'Box after add: ' + _box!.values.map((e) => e.title).join(', '),
      );

      // Clean up old entries
      _cleanupOldEntries();
    } catch (e, stack) {
      _logger.severe('Error adding recent play', e, stack);
    }
  }

  Future<void> _cleanupOldEntries() async {
    try {
      if (_box == null || _box!.length <= _maxRecentPlays) return;

      var entries = _box!.values.toList();
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Keep only the most recent entries
      var entriesToRemove = entries.sublist(_maxRecentPlays);
      for (var entry in entriesToRemove) {
        if (entry.key != null) {
          await _box!.delete(entry.key);
        }
      }

      _logger.info('Cleaned up old entries. Current count: ${_box!.length}');
    } catch (e, stack) {
      _logger.severe('Error cleaning up old entries', e, stack);
    }
  }

  List<RecentPlay> getRecentPlays() {
    if (_box == null) return [];
    return _box!.values.toList().reversed.toList();
  }

  Future<void> updatePlayPosition(String audioUrl, int position) async {
    try {
      if (_box == null) return;

      var entries = _box!.values.toList();
      var index = entries.indexWhere((item) => item.audioUrl == audioUrl);

      if (index != -1) {
        var entry = entries[index];
        var updatedEntry = RecentPlay(
          title: entry.title,
          artist: entry.artist,
          audioUrl: entry.audioUrl,
          artUri: entry.artUri,
          album: entry.album,
          timestamp: DateTime.now(), // Update timestamp to keep it recent
          localFilePath: entry.localFilePath,
          isDownloaded: entry.isDownloaded,
          chapterSlug: entry.chapterSlug,
          ebookSlug: entry.ebookSlug,
          lastPosition: position,
        );

        if (entry.key != null) {
          await _box!.put(entry.key, updatedEntry);
          _logger.fine('Updated position for ${entry.title}: $position');
        }
      }
    } catch (e, stack) {
      _logger.severe('Error updating play position', e, stack);
    }
  }

  Future<void> clearRecentPlays() async {
    try {
      await _box?.clear();
      _logger.info('Recent plays cleared');
    } catch (e, stack) {
      _logger.severe('Error clearing recent plays', e, stack);
    }
  }

  Future<void> dispose() async {
    try {
      await _boxSubscription?.cancel();
      await _recentPlaysController.close();
      await _box?.close();
    } catch (e, stack) {
      _logger.severe('Error disposing RecentPlaysService', e, stack);
    }
  }
}
