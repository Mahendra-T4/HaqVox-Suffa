import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:haqvox/app/core/database/hive_database.dart';
import 'package:haqvox/app/core/database/hive_models/downloaded_audio_model.dart';

class DownloadsDatabase {
  static const String _boxName = 'downloads';

  // Initialize - just ensure HiveDatabase is initialized (box is opened there)
  static Future<void> init() async {
    // HiveDatabase will handle opening all boxes including 'downloads'
    // This method is kept for backward compatibility
    // No need to do anything here since HiveDatabase.init() is called in main.dart
  }

  // Get singleton instance of the box from HiveDatabase
  static Box<DownloadedAudioModel> get box => HiveDatabase().downloadBox;

  // Get all downloads
  Future<List<DownloadedAudioModel>> getAllDownloads() async {
    return box.values.toList();
  }

  // Get downloads by chapter slug
  Future<List<DownloadedAudioModel>> getDownloadsByChapter(
    String chapterSlug,
  ) async {
    return box.values
        .where((audio) => audio.chapterSlug == chapterSlug)
        .toList();
  }

  // Get single download by URL
  Future<DownloadedAudioModel?> getDownloadByUrl(String url) async {
    try {
      final index = box.values.toList().indexWhere((audio) => audio.url == url);
      if (index != -1) {
        return box.getAt(index);
      }
      return null;
    } catch (e) {
      print('Error getting download by URL: $e');
      return null;
    }
  }

  // Insert a new download
  Future<String> insertDownload(DownloadedAudioModel download) async {
    try {
      await box.put(download.id, download);
      return download.id;
    } catch (e) {
      print('Error inserting download: $e');
      rethrow;
    }
  }

  // Delete a single download by ID
  Future<bool> deleteDownload(String id) async {
    try {
      final download = box.get(id);
      if (download != null) {
        // Delete the local file if it exists
        final file = File(download.localPath);
        if (await file.exists()) {
          await file.delete();
        }
        // Delete from Hive
        await box.delete(id);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting download: $e');
      return false;
    }
  }

  // Delete all downloads
  Future<void> deleteAllDownloads() async {
    try {
      final downloads = box.values.toList();
      for (final download in downloads) {
        try {
          final file = File(download.localPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting file: $e');
        }
      }
      await box.clear();
    } catch (e) {
      print('Error deleting all downloads: $e');
      rethrow;
    }
  }

  // Get download count
  Future<int> getDownloadCount() async {
    return box.length;
  }

  // Get total size of all downloads
  Future<int> getTotalDownloadSize() async {
    int totalSize = 0;
    for (final audio in box.values) {
      totalSize += audio.fileSize;
    }
    return totalSize;
  }

  // Update an existing download
  Future<void> updateDownload(String id, DownloadedAudioModel download) async {
    try {
      await box.put(id, download);
    } catch (e) {
      print('Error updating download: $e');
      rethrow;
    }
  }

  // Search downloads by title
  Future<List<DownloadedAudioModel>> searchByTitle(String query) async {
    return box.values
        .where(
          (audio) => audio.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Search downloads by artist
  Future<List<DownloadedAudioModel>> searchByArtist(String query) async {
    return box.values
        .where(
          (audio) => audio.artist.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Check if download exists by URL
  Future<bool> downloadExists(String url) async {
    return box.values.any((audio) => audio.url == url);
  }

  // Close the Hive box
  Future<void> close() async {
    await box.close();
  }

  // Delete the Hive box
  Future<void> deleteBox() async {
    await Hive.deleteBoxFromDisk(_boxName);
  }
}
