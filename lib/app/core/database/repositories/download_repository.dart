import 'dart:io';
import 'package:haqvox/app/core/database/hive_database.dart';
import 'package:haqvox/app/core/database/hive_models/downloaded_audio_model.dart';

/// Download Repository - Handles all download-related database operations
class DownloadRepository {
  final HiveDatabase _hiveDatabase = HiveDatabase();

  /// Get all downloads
  Future<List<DownloadedAudioModel>> getAllDownloads() async {
    try {
      return _hiveDatabase.downloadBox.values.toList();
    } catch (e) {
      print('Error getting all downloads: $e');
      return [];
    }
  }

  /// Get downloads by chapter slug
  Future<List<DownloadedAudioModel>> getDownloadsByChapter(
    String chapterSlug,
  ) async {
    try {
      return _hiveDatabase.downloadBox.values
          .where((audio) => audio.chapterSlug == chapterSlug)
          .toList();
    } catch (e) {
      print('Error getting downloads by chapter: $e');
      return [];
    }
  }

  /// Get downloads by ebook slug
  Future<List<DownloadedAudioModel>> getDownloadsByEbook(
    String ebookSlug,
  ) async {
    try {
      return _hiveDatabase.downloadBox.values
          .where((audio) => audio.ebookSlug == ebookSlug)
          .toList();
    } catch (e) {
      print('Error getting downloads by ebook: $e');
      return [];
    }
  }

  /// Get single download by URL
  Future<DownloadedAudioModel?> getDownloadByUrl(String url) async {
    try {
      final downloads = _hiveDatabase.downloadBox.values
          .where((audio) => audio.url == url)
          .toList();
      return downloads.isNotEmpty ? downloads.first : null;
    } catch (e) {
      print('Error getting download by URL: $e');
      return null;
    }
  }

  /// Get download by ID
  Future<DownloadedAudioModel?> getDownloadById(String id) async {
    try {
      return _hiveDatabase.downloadBox.get(id);
    } catch (e) {
      print('Error getting download by ID: $e');
      return null;
    }
  }

  /// Insert or update download
  Future<void> saveDownload(DownloadedAudioModel download) async {
    try {
      await _hiveDatabase.downloadBox.put(download.id, download);
    } catch (e) {
      print('Error saving download: $e');
      rethrow;
    }
  }

  /// Update download progress
  Future<void> updateDownloadProgress(String id, int progress) async {
    try {
      final download = await getDownloadById(id);
      if (download != null) {
        download.downloadProgress = progress;
        await saveDownload(download);
      }
    } catch (e) {
      print('Error updating download progress: $e');
      rethrow;
    }
  }

  /// Update download status
  Future<void> updateDownloadStatus(String id, String status) async {
    try {
      final download = await getDownloadById(id);
      if (download != null) {
        download.status = status;
        await saveDownload(download);
      }
    } catch (e) {
      print('Error updating download status: $e');
      rethrow;
    }
  }

  /// Delete download by ID
  Future<bool> deleteDownloadById(String id) async {
    try {
      final download = await getDownloadById(id);
      if (download != null) {
        // Delete the local file if it exists
        try {
          final file = File(download.localPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Warning: Could not delete file: $e');
        }
        // Delete from Hive
        await _hiveDatabase.downloadBox.delete(id);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting download: $e');
      return false;
    }
  }

  /// Delete download by URL
  Future<bool> deleteDownloadByUrl(String url) async {
    try {
      final download = await getDownloadByUrl(url);
      if (download != null) {
        return await deleteDownloadById(download.id);
      }
      return false;
    } catch (e) {
      print('Error deleting download by URL: $e');
      return false;
    }
  }

  /// Delete all downloads
  Future<void> deleteAllDownloads() async {
    try {
      final downloads = await getAllDownloads();
      for (final download in downloads) {
        try {
          final file = File(download.localPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Warning: Could not delete file: $e');
        }
      }
      await _hiveDatabase.downloadBox.clear();
    } catch (e) {
      print('Error deleting all downloads: $e');
      rethrow;
    }
  }

  /// Get downloads count
  Future<int> getDownloadsCount() async {
    try {
      return _hiveDatabase.downloadBox.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get total download size
  Future<int> getTotalDownloadSize() async {
    try {
      final downloads = await getAllDownloads();
      return downloads.fold<int>(0, (sum, download) => sum + download.fileSize);
    } catch (e) {
      return 0;
    }
  }

  /// Check if file exists locally
  Future<bool> isDownloaded(String url) async {
    try {
      final download = await getDownloadByUrl(url);
      if (download != null) {
        final file = File(download.localPath);
        return await file.exists();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Watch downloads (stream)
  Stream<List<DownloadedAudioModel>> watchDownloads() async* {
    try {
      yield await getAllDownloads();
      await for (final _ in _hiveDatabase.downloadBox.watch()) {
        yield await getAllDownloads();
      }
    } catch (e) {
      print('Error watching downloads: $e');
      yield [];
    }
  }
}
