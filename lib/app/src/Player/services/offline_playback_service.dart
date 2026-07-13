import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:logging/logging.dart';
import '../../downloads/services/download_manager.dart';

class OfflinePlaybackService {
  static final OfflinePlaybackService _instance =
      OfflinePlaybackService._internal();
  factory OfflinePlaybackService() => _instance;
  OfflinePlaybackService._internal();

  final DownloadManager _downloadManager = DownloadManager();
  final _logger = Logger('OfflinePlaybackService');

  Future<List<MediaItem>> getOfflinePlaylist() async {
    try {
      final downloads = await _downloadManager.getAllDownloads();
      final mediaItems = <MediaItem>[];

      for (final download in downloads) {
        final file = File(download.localPath);
        if (await file.exists()) {
          // Parse artwork URL safely
          Uri? artUri;
          if (download.coverUrl != null && download.coverUrl!.isNotEmpty) {
            try {
              artUri = Uri.parse(download.coverUrl!);
            } catch (e) {
              _logger.warning('Failed to parse coverUrl: ${download.coverUrl}');
            }
          }

          mediaItems.add(
            MediaItem(
              id: download.id,
              title: download.title,
              artist: download.artist,
              album: 'Offline Music',
              artUri: artUri,
              extras: {
                'url': download.url,
                'localFilePath': download.localPath,
                'isDownloaded': true,
                'audioSlug': download.id,
                'chapterSlug': download.chapterSlug,
                'ebookSlug': download.ebookSlug,
              },
            ),
          );
        } else {
          // File doesn't exist, clean up the database
          _logger.warning('Downloaded file not found: ${download.localPath}');
          await _downloadManager.deleteDownload(download.url);
        }
      }

      return mediaItems;
    } catch (e, stack) {
      _logger.severe('Error getting offline playlist', e, stack);
      rethrow;
    }
  }

  Future<bool> isOfflineAvailable(String url) async {
    try {
      final localPath = await _downloadManager.getLocalPath(url);
      if (localPath == null) return false;

      final file = File(localPath);
      return await file.exists();
    } catch (e, stack) {
      _logger.severe('Error checking offline availability', e, stack);
      return false;
    }
  }

  Future<String?> getOfflineFilePath(String url) async {
    try {
      final localPath = await _downloadManager.getLocalPath(url);
      if (localPath != null) {
        final file = File(localPath);
        if (await file.exists()) {
          return localPath;
        }
      }
      return null;
    } catch (e, stack) {
      _logger.severe('Error getting offline file path', e, stack);
      return null;
    }
  }
}
