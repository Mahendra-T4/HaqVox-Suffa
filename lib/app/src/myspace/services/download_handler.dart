import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../model/offline_music.dart';
import 'package:logging/logging.dart';
import '../services/offline_music_service.dart';

class DownloadHandler {
  static final OfflineMusicService _musicService = OfflineMusicService.instance;
  static final _logger = Logger('DownloadHandler');

  /// Downloads music from a URL and saves it to local storage
  ///
  /// [url] The URL of the music file to download
  /// [title] The title of the music
  /// [artist] The artist name
  /// [duration] The duration of the music
  /// [onProgress] Optional callback for download progress (0.0 to 1.0)
  static Future<void> downloadMusic({
    required String url,
    required String title,
    required String artist,
    required String duration,
    void Function(double)? onProgress,
  }) async {
    final client = http.Client();
    try {
      // Validate inputs
      if (url.isEmpty || !Uri.parse(url).isAbsolute) {
        throw ArgumentError('Invalid URL provided');
      }
      if (title.isEmpty) throw ArgumentError('Title cannot be empty');
      if (artist.isEmpty) throw ArgumentError('Artist cannot be empty');
      if (duration.isEmpty) throw ArgumentError('Duration cannot be empty');

      // Start download with progress tracking
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw HttpException('Failed to download file: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      int received = 0;

      // Get app's local storage directory
      final appDir = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${appDir.path}/offline_music');

      // Create music directory if it doesn't exist
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      // Generate unique filename with sanitized title
      final sanitizedTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = path.extension(url).isNotEmpty ? path.extension(url) : '.mp3';
      final filename = '${sanitizedTitle}_${timestamp}$ext';
      final filePath = '${musicDir.path}/$filename';

      // Create file
      final file = File(filePath);
      final sink = file.openWrite();

      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (contentLength > 0 && onProgress != null) {
            onProgress(received / contentLength);
          }
        }
      } finally {
        await sink.close();
      }

      // Verify file was downloaded successfully
      if (!await file.exists()) {
        throw FileSystemException('Failed to save file');
      }

      // Create OfflineMusic object
      final music = OfflineMusic(
        id: timestamp.toString(),
        title: title,
        artist: artist,
        filePath: filePath,
        duration: duration,
        downloadDate: DateTime.now(),
      );

      // Save music metadata
      await _musicService.saveMusic(music);

      _logger.info('Successfully downloaded and saved: $title');
    } catch (e, stack) {
      _logger.severe('Error downloading music', e, stack);
      // Clean up partial downloads if there was an error
      try {
        final failedFile = File(
            '${(await getApplicationDocumentsDirectory()).path}/offline_music/${title}_${DateTime.now().millisecondsSinceEpoch}');
        if (await failedFile.exists()) {
          await failedFile.delete();
        }
      } catch (cleanupError) {
        _logger.warning('Failed to clean up partial download', cleanupError);
      }
      rethrow;
    } finally {
      client.close();
    }
  }
}
