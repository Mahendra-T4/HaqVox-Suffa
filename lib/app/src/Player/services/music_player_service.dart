import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:logging/logging.dart';
import 'package:get_it/get_it.dart';
import '../models/track_model.dart';
import 'audio_player_handler.dart';
import 'offline_playback_service.dart';
import 'recent_plays_service.dart';

class MusicPlayerService {
  final AudioPlayerHandler _handler;
  final _logger = Logger('MusicPlayerService');
  final _offlinePlaybackService = OfflinePlaybackService();
  final _recentPlaysService = GetIt.I<RecentPlaysService>();
  bool _initialized = false;
  final _initCompleter = Completer<void>();

  bool get isInitialized => _initialized;

  MusicPlayerService(this._handler) {
    _initializeService();
  }

  Future<void> waitForInitialization() => _initCompleter.future;

  Future<void> _initializeService() async {
    if (_initialized) {
      _initCompleter.complete();
      return;
    }

    try {
      _logger.info('Initializing MusicPlayerService...');

      // Wait for handler to be ready
      bool handlerReady = false;
      for (int i = 0; i < 5; i++) {
        try {
          // Test if handler is responsive
          await _handler.customAction('ping');
          handlerReady = true;
          break;
        } catch (_) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      if (!handlerReady) {
        throw Exception('AudioHandler not responding after initialization');
      }

      // Set up media item listener first
      _handler.mediaItem.listen(
        (mediaItem) {
          if (mediaItem != null) {
            _recentPlaysService.addToRecent(mediaItem);
          }
        },
        onError: (e) {
          _logger.warning('Error in mediaItem stream: $e');
        },
      );

      // Set up other essential streams
      _handler.playbackState.listen(
        (state) {
          // Handle playback state changes
        },
        onError: (e) {
          _logger.warning('Error in playbackState stream: $e');
        },
      );

      _initialized = true;
      _logger.info('MusicPlayerService initialized successfully');
      _initCompleter.complete();
    } catch (e, stack) {
      _logger.severe('Error initializing MusicPlayerService', e, stack);
      _initialized = false;
      _initCompleter.completeError(e);
      throw e; // Re-throw to let the caller handle it
    }
  }

  // Playback state streams
  Stream<MediaItem?> get currentTrack => _handler.mediaItem;
  Stream<PlaybackState> get playbackState => _handler.playbackState;
  Stream<List<MediaItem>> get queue => _handler.queue;
  Stream<Duration> get position => _handler.position;
  Stream<Duration?> get duration => _handler.duration;
  Stream<double> get volume => _handler.volume;
  Stream<double> get speed => _handler.speed;
  // Track playback functions
  Future<void> playTracks(List<Track> tracks, {int initialIndex = 0}) async {
    try {
      _logger.info(
        'Playing tracks: count=${tracks.length}, initial=${initialIndex}',
      );

      // Ensure service is initialized before proceeding
      if (!_initialized) {
        _logger.info('Waiting for MusicPlayerService initialization...');
        await waitForInitialization();
      }

      print('PLAYTRACKS: Service initialized, tracks=${tracks.length}');

      // Convert tracks to media items
      final mediaItems =
          tracks.map((track) {
            final mediaItem = track.toMediaItem();
            _logger.info(
              'Track converted: title=${mediaItem.title}, artist=${mediaItem.artist}, artUri=${mediaItem.artUri}',
            );
            print(
              'PLAYTRACKS: Converted - ${mediaItem.title}, isOffline=${mediaItem.extras?['isDownloaded']}, localPath=${mediaItem.extras?['localFilePath']}',
            );
            return mediaItem;
          }).toList();

      // Always stop current playback first
      await _handler.stop();

      // Update queue with new tracks
      await _handler.updateQueue(mediaItems);

      // Skip to the requested track
      await _handler.skipToQueueItem(initialIndex);

      // Start playing
      await _handler.play();

      _logger.info('Playback started successfully');
      print('PLAYTRACKS: Playback started');
    } catch (e, stack) {
      _logger.severe('Error playing tracks', e, stack);
      print('PLAYTRACKS ERROR: $e');
      rethrow;
    }
  }

  Future<void> playOfflineTrack(MediaItem track) async {
    try {
      // Ensure service is initialized before proceeding
      if (!_initialized) {
        _logger.info('Waiting for MusicPlayerService initialization...');
        await waitForInitialization();
      }

      final localPath = track.extras?['localFilePath'] as String?;
      if (localPath == null) {
        throw Exception('No local file path found for offline track');
      }

      final file = File(localPath);
      if (!await file.exists()) {
        throw Exception('Offline track file not found: $localPath');
      }

      await _handler.stop();
      await _handler.addQueueItems([track]);
      await _handler.skipToQueueItem(0);
      await _handler.play();
    } catch (e, stack) {
      _logger.severe('Error playing offline track', e, stack);
      rethrow;
    }
  }

  Future<void> playOfflinePlaylist(
    List<MediaItem> offlineTracks, {
    int initialIndex = 0,
  }) async {
    try {
      _logger.info(
        'Playing offline playlist: ${offlineTracks.length} tracks, starting at $initialIndex',
      );

      // Ensure service is initialized before proceeding
      if (!_initialized) {
        _logger.info('Waiting for MusicPlayerService initialization...');
        await waitForInitialization();
      }

      // Log first track details for debugging
      if (offlineTracks.isNotEmpty) {
        final firstTrack = offlineTracks[initialIndex];
        _logger.info(
          'Initial track details: title=${firstTrack.title}, chapter=${firstTrack.artist}, image=${firstTrack.artUri}',
        );
        _logger.info('Track extras: ${firstTrack.extras}');
      }

      // Stop current playback first
      await _handler.stop();

      // Update queue with all offline tracks (handles clearing and adding)
      await _handler.updateQueue(offlineTracks);

      // Skip to initial track and start playback
      await _handler.skipToQueueItem(initialIndex);
      await _handler.play();

      _logger.info('Offline playlist started successfully');
    } catch (e, stack) {
      _logger.severe('Error playing offline playlist', e, stack);
      rethrow;
    }
  }

  Future<List<MediaItem>> getOfflinePlaylist() async {
    try {
      return await _offlinePlaybackService.getOfflinePlaylist();
    } catch (e, stack) {
      _logger.severe('Error getting offline playlist', e, stack);
      rethrow;
    }
  }

  Future<bool> isOfflineAvailable(String url) async {
    try {
      return await _offlinePlaybackService.isOfflineAvailable(url);
    } catch (e, stack) {
      _logger.severe('Error checking offline availability', e, stack);
      return false;
    }
  }

  Future<void> addToQueue(List<Track> tracks) async {
    try {
      final mediaItems = tracks.map((track) => track.toMediaItem()).toList();
      await _handler.addQueueItems(mediaItems);
    } catch (e, stack) {
      _logger.severe('Error adding tracks to queue', e, stack);
    }
  }

  Future<void> play() => _handler.play();
  Future<void> pause() => _handler.pause();
  Future<void> stop() => _handler.stop();
  Future<void> skipToNext() => _handler.skipToNext();
  Future<void> skipToPrevious() => _handler.skipToPrevious();
  Future<void> seek(Duration position) => _handler.seek(position);
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) =>
      _handler.setRepeatMode(repeatMode);
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) =>
      _handler.setShuffleMode(shuffleMode);

  // Equalizer controls
  Future<void> setEqualizer(bool enabled) => _handler.setEqualizer(enabled);
  Future<void> setEqualizerBand(int bandIndex, double gain) =>
      _handler.setEqualizerBand(bandIndex, gain);
  Future<void> initializeEqualizer() => _handler.initializeEqualizer();

  // Sleep timer control
  Future<void> setSleepTimer(int minutes) async {
    try {
      await _handler.customAction('sleepTimer', {'minutes': minutes});
    } catch (e, stack) {
      _logger.severe('Error setting sleep timer', e, stack);
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _handler.setVolume(volume);
    } catch (e, stack) {
      _logger.severe('Error setting volume', e, stack);
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _handler.setSpeed(speed);
    } catch (e, stack) {
      _logger.severe('Error setting speed', e, stack);
    }
  }

  // Initialize the service
  static Future<MusicPlayerService> init(AudioPlayerHandler handler) async {
    return MusicPlayerService(handler);
  }

  void dispose() {
    _handler.dispose();
  }
}
