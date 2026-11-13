import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:haqvox/app/core/database/hive_models/downloaded_audio_model.dart';
import '../database/downloads_hive_db.dart';

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final DownloadsDatabase _database = DownloadsDatabase();
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};

  DownloadsDatabase getDatabase() {
    return _database;
  }

  Future<bool> _hasPermissions() async {
    // App-scoped storage (getApplicationDocumentsDirectory) doesn't require permission on Android
    return true;
  }

  Future<String?> _createDownloadDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsPath = p.join(directory.path, 'audio_downloads');

      final dir = Directory(downloadsPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      return downloadsPath;
    } catch (e) {
      print('Error creating downloads directory: $e');
      return null;
    }
  }

  Future<String?> downloadAudio({
    required String url,
    required String fileName,
    required String title,
    required String artist,
    required String chapterTitle,
    required String chapterSlug,
    required String ebookSlug,
    required String ebookTitle,
    String? coverUrl,
  }) async {
    try {
      if (_isDownloading[url] == true) {
        print('Already downloading: $url');
        return null;
      }

      // Check permissions first
      if (!await _hasPermissions()) {
        throw Exception(
          'Storage permission is required to download audio files. Please grant permission in Settings.',
        );
      }

      // Get download directory
      final downloadsPath = await _createDownloadDirectory();
      if (downloadsPath == null) {
        throw Exception('Could not create downloads directory');
      }

      _isDownloading[url] = true;
      _downloadProgress[url] = 0.0;

      final db = getDatabase();

      // Check if already downloaded
      final existingDownload = await db.getDownloadByUrl(url);
      if (existingDownload != null) {
        final file = File(existingDownload.localPath);
        if (await file.exists()) {
          _isDownloading[url] = false;
          print('File already exists: ${existingDownload.localPath}');
          return existingDownload.localPath;
        } else {
          await db.deleteDownload(existingDownload.id);
        }
      }
      final filePath = p.join(downloadsPath, fileName);
      print('Downloading to: $filePath');

      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final file = File(filePath);
        final contentLength = response.contentLength ?? 0;
        final sink = file.openWrite();
        int receivedBytes = 0;

        await for (final chunk in response.stream) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          updateProgress(
            url,
            contentLength > 0 ? receivedBytes / contentLength : 0,
          );
        }
        await sink.close();

        if (!await file.exists()) {
          throw Exception('File was not created successfully');
        }

        // Verify file size
        final fileSize = await file.length();
        if (fileSize == 0) {
          await file.delete();
          throw Exception('Downloaded file is empty');
        }

        // Save to database
        final download = DownloadedAudioModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          url: url,
          localPath: filePath,
          artist: artist,
          coverUrl: coverUrl,
          fileSize: fileSize,
          downloadDate: DateTime.now(),
          chapterTitle: chapterTitle,
          chapterSlug: chapterSlug,
          ebookSlug: ebookSlug,
          ebookTitle: ebookTitle,
        );

        await db.insertDownload(download);
        _isDownloading[url] = false;
        _downloadProgress[url] = 1.0;
        print('Download completed: $filePath');
        return filePath;
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading audio: $e');
      _isDownloading[url] = false;
      _downloadProgress[url] = 0.0;
      rethrow;
    }
  }

  Future<bool> isDownloaded(String url) async {
    final db = getDatabase();
    final download = await db.getDownloadByUrl(url);
    if (download != null) {
      return await File(download.localPath).exists();
    }
    return false;
  }

  Future<String?> getLocalPath(String url) async {
    final db = getDatabase();
    final download = await db.getDownloadByUrl(url);
    if (download != null) {
      final file = File(download.localPath);
      if (await file.exists()) {
        return download.localPath;
      } else {
        await db.deleteDownload(download.id);
      }
    }
    return null;
  }

  Future<List<DownloadedAudioModel>> getAllDownloads() async {
    final db = getDatabase();
    return await db.getAllDownloads();
  }

  Future<List<DownloadedAudioModel>> getDownloadsByChapter(
    String chapterSlug,
  ) async {
    final db = getDatabase();
    return await db.getDownloadsByChapter(chapterSlug);
  }

  Future<bool> deleteDownload(String url) async {
    final db = getDatabase();
    final download = await db.getDownloadByUrl(url);
    if (download != null) {
      return await db.deleteDownload(download.id);
    }
    return false;
  }

  Future<void> deleteAllDownloads() async {
    final db = getDatabase();
    await db.deleteAllDownloads();
  }

  bool isDownloading(String url) => _isDownloading[url] ?? false;
  double getProgress(String url) => _downloadProgress[url] ?? 0.0;

  List<String> getDownloadingFiles() {
    return _isDownloading.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  Stream<double> getDownloadProgressStream(String url) async* {
    while (_isDownloading[url] == true) {
      yield _downloadProgress[url] ?? 0.0;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void updateProgress(String url, double progress) {
    _downloadProgress[url] = progress;
  }

  void cancelDownload(String url) {
    _isDownloading[url] = false;
    // Optionally, reset progress or add more logic if needed
    _downloadProgress[url] = 0.0;
  }

  Future<int> getTotalDownloadSize() async {
    try {
      final downloads = await getAllDownloads();
      int totalSize = 0;

      for (var download in downloads) {
        final file = File(download.localPath);
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      print('Error calculating total size: $e');
      return 0;
    }
  }

  void dispose() {
    // No need to dispose Hive - it's managed by DownloadsDatabase
  }
}
