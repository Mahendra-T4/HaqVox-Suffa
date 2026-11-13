import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:logging/logging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';
import '../models/track_model.dart';
import '../models/equalizer_parameters.dart';
import '../services/recent_plays_service.dart';

/// Enhanced audio handler implementation with BlackHole-style features
class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  final _logger = Logger('AudioPlayerHandler');
  Timer? _sleepTimer;
  Timer? _fadeOutTimer;
  late final RecentPlaysService _recentPlaysService;

  // Storage box name
  static const String _queueBoxName = 'audioQueue';
  static const String _queueKey = 'queue';
  static const String _queueIndexKey = 'index';
  Box? _queueBox;

  // State management
  final _mediaItemQueue = BehaviorSubject<List<MediaItem>>.seeded([]);
  final _volume = BehaviorSubject<double>.seeded(1.0);
  final _speed = BehaviorSubject<double>.seeded(1.0);
  // bool _wasPlayingBeforeInterruption = false;

  // Sleep timer state
  static const _fadeOutDuration = Duration(seconds: 30);
  final _sleepTimerEnabled = BehaviorSubject<bool>.seeded(false);
  final _sleepTimerRemaining = BehaviorSubject<Duration?>.seeded(null);

  // Equalizer state
  AndroidEqualizer? _equalizer;
  final BehaviorSubject<bool> _equalizerEnabled = BehaviorSubject.seeded(false);
  final BehaviorSubject<EqualizerParameters> _equalizerParams =
      BehaviorSubject();

  AudioPlayerHandler() {
    _init();
    _recentPlaysService = GetIt.I<RecentPlaysService>();
  }
  Future<void> _init() async {
    try {
      _logger.info('Starting AudioPlayerHandler initialization...');

      // Initialize playback state
      playbackState.add(
        PlaybackState(
          processingState: AudioProcessingState.idle,
          playing: false,
          updatePosition: Duration.zero,
          bufferedPosition: Duration.zero,
          speed: 1.0,
          queueIndex: 0,
        ),
      );

      // Configure audio session first
      await _configureAudioSession();
      _logger.info('Audio session configured');

      // Initialize the player with error handling
      try {
        await _player.setAudioSource(_playlist, preload: false);
      } catch (e) {
        _logger.warning(
          'Error setting initial audio source, continuing anyway: $e',
        );
      }

      // Set up error handling for the player
      _player.playbackEventStream.listen(
        (event) {
          // Handle normal events
        },
        onError: (Object e, StackTrace? stackTrace) {
          _logger.severe('Error from player', e, stackTrace);
          playbackState.add(
            playbackState.value.copyWith(
              processingState: AudioProcessingState.error,
            ),
          );
        },
      );

      // Initialize equalizer with error handling
      try {
        _equalizer = AndroidEqualizer();
        await _equalizer?.setEnabled(true);
        await initializeEqualizer();
        _logger.info('Equalizer initialized');
      } catch (e) {
        _logger.warning('Error initializing equalizer, continuing anyway: $e');
      }

      // Open Hive box for queue persistence
      try {
        _queueBox = await Hive.openBox(_queueBoxName);
        _logger.info('Queue box opened');
      } catch (e) {
        _logger.warning('Error opening queue box, continuing anyway: $e');
      }

      // Load saved queue if available
      try {
        await _loadSavedQueue();
        _logger.info('Saved queue loaded');
      } catch (e) {
        _logger.warning('Error loading saved queue, continuing anyway: $e');
      }

      // Set up event listeners
      _setupEventListeners();
      _logger.info('Event listeners set up');

      _logger.info('AudioPlayerHandler initialized successfully');
    } catch (e, stack) {
      _logger.severe('Error initializing audio handler', e, stack);
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
        ),
      );
      throw e; // Re-throw to let callers know about initialization failure
    }
  }

  Future<void> _configureAudioSession() async {
    try {
      _logger.info('Configuring audio session...');
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.media,
            flags: AndroidAudioFlags.none,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ),
      );
      _logger.info('Audio session configured successfully');
    } catch (e, stack) {
      _logger.severe('Error configuring audio session', e, stack);
      rethrow;
    }
  }

  void _setupEventListeners() {
    // Update playback state
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState:
              const {
                ProcessingState.idle: AudioProcessingState.idle,
                ProcessingState.loading: AudioProcessingState.loading,
                ProcessingState.buffering: AudioProcessingState.buffering,
                ProcessingState.ready: AudioProcessingState.ready,
                ProcessingState.completed: AudioProcessingState.completed,
              }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: event.currentIndex,
        ),
      );
    });

    // Update media item on track change
    _player.currentIndexStream.listen((index) async {
      if (index != null &&
          _mediaItemQueue.hasValue &&
          index < _mediaItemQueue.value.length) {
        final newMediaItem = _mediaItemQueue.value[index];
        _logger.info(
          'Switching to track: ${newMediaItem.title}, ${newMediaItem.artist}, artUri: ${newMediaItem.artUri}',
        );

        // Create a fresh MediaItem to ensure all metadata is up to date
        final currentTrack = Track.fromMediaItem(newMediaItem);
        final updatedMediaItem = currentTrack.toMediaItem();

        // Update the current media item
        mediaItem.add(updatedMediaItem);

        // Save queue state
        await _saveQueueState();
      }
    });

    // Handle playback completion
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handlePlaybackCompletion();
      }
    });

    // Listen for sequence state changes
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState.currentSource != null) {
        final mediaItem = sequenceState.currentSource!.tag as MediaItem;
        _logger.info(
          'Current track updated: ${mediaItem.title}, ${mediaItem.artist}',
        );
      }
    });

    // Track position updates for recent plays
    _player.positionStream.listen((position) async {
      try {
        final currentItem = mediaItem.value;
        if (currentItem != null) {
          final url = currentItem.extras?['url'] as String? ?? currentItem.id;
          await _recentPlaysService.updatePlayPosition(
            url,
            position.inMilliseconds,
          );
        }
      } catch (e, stack) {
        _logger.severe('Error updating play position', e, stack);
      }
    });
  }

  Future<void> _saveQueueState() async {
    try {
      if (_queueBox == null) return;

      final queue = _mediaItemQueue.value;
      final queueData =
          queue
              .map(
                (item) => {
                  'id': item.id,
                  'title': item.title,
                  'album': item.album,
                  'artist': item.artist,
                  'genre': item.genre,
                  'duration': item.duration?.inMilliseconds,
                  'artUri': item.artUri?.toString(),
                  'extras': item.extras,
                },
              )
              .toList();

      await _queueBox?.put(_queueKey, queueData);
      await _queueBox?.put(_queueIndexKey, _player.currentIndex ?? 0);
      _logger.fine('Queue state saved successfully');
    } catch (e, stack) {
      _logger.severe('Error saving queue state', e, stack);
    }
  }

  Future<void> _loadSavedQueue() async {
    try {
      if (_queueBox == null) return;

      final queueData = _queueBox?.get(_queueKey) as List?;
      final currentIndex = _queueBox?.get(_queueIndexKey) as int? ?? 0;

      if (queueData != null) {
        final queue =
            queueData.map((item) {
              final map = Map<String, dynamic>.from(item as Map);
              return MediaItem(
                id: map['id'] as String,
                title: map['title'] as String,
                album: map['album'] as String?,
                artist: map['artist'] as String?,
                genre: map['genre'] as String?,
                duration:
                    map['duration'] != null
                        ? Duration(milliseconds: map['duration'] as int)
                        : null,
                artUri:
                    map['artUri'] != null
                        ? Uri.parse(map['artUri'] as String)
                        : null,
                extras: map['extras'] as Map<String, dynamic>?,
              );
            }).toList();

        _mediaItemQueue.add(queue);
        final sources = queue.map(_createAudioSource).toList();
        await _playlist.addAll(sources);
        if (currentIndex < queue.length) {
          await skipToQueueItem(currentIndex);
        }
      }
    } catch (e, stack) {
      _logger.severe('Error loading saved queue', e, stack);
    }
  }

  void _handlePlaybackCompletion() {
    if (_player.hasNext) {
      _player.seekToNext();
    } else {
      stop();
    }
  }

  /// Forces emission of current MediaItem with fresh metadata
  Future<void> _updateCurrentMediaItem() async {
    if (_player.currentIndex != null &&
        _mediaItemQueue.hasValue &&
        _player.currentIndex! < _mediaItemQueue.value.length) {
      final currentMediaItem = _mediaItemQueue.value[_player.currentIndex!];
      final currentTrack = Track.fromMediaItem(currentMediaItem);
      final updatedMediaItem = currentTrack.toMediaItem();
      _logger.info(
        'Updating current MediaItem: ${updatedMediaItem.title}, ${updatedMediaItem.artist}, artUri: ${updatedMediaItem.artUri}',
      );
      mediaItem.add(updatedMediaItem);
    }
  }

  // Playback controls
  @override
  Future<void> play() async {
    try {
      _logger.info('Attempting to play...');

      // Add current item to recent plays
      final currentItem = mediaItem.value;
      if (currentItem != null) {
        await _recentPlaysService.addToRecent(currentItem);
        _logger.info('Added to recent plays: ${currentItem.title}');
      }

      await _player.play();
      playbackState.add(
        playbackState.value.copyWith(
          playing: true,
          processingState: AudioProcessingState.ready,
        ),
      );
      _logger.info('Play command executed successfully');
    } catch (e, stack) {
      _logger.severe('Error during play command', e, stack);
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      _logger.info('Attempting to pause...');
      await _player.pause();
      playbackState.add(playbackState.value.copyWith(playing: false));
      _logger.info('Pause command executed successfully');
    } catch (e, stack) {
      _logger.severe('Error during pause command', e, stack);
      rethrow;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      // Update state first for immediate UI feedback
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
      // Then perform the actual seek
      await _player.seek(position);

      // Update recent play position
      if (mediaItem.hasValue) {
        await _recentPlaysService.updatePlayPosition(
          mediaItem.value!.id,
          position.inMilliseconds,
        );
      }
    } catch (e, stack) {
      _logger.severe('Error seeking to position', e, stack);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    try {
      if (index < 0 || index >= _mediaItemQueue.value.length) return;
      _logger.info('Skipping to queue item at index $index');
      await _player.seek(Duration.zero, index: index);
      await _updateCurrentMediaItem();
    } catch (e, stack) {
      _logger.severe('Error skipping to queue item', e, stack);
    }
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      await super.stop();
      // Save queue state when stopped
      await _saveQueueState();
    } catch (e, stack) {
      _logger.severe('Error stopping playback', e, stack);
    }
  }

  Future<void> clearQueue() async {
    try {
      await _player.stop();
      await updateQueue([]);
      await _queueBox?.delete(_queueKey);
      await _queueBox?.delete(_queueIndexKey);
      await super.stop();
      playbackState.add(
        playbackState.value.copyWith(
          controls: [],
          processingState: AudioProcessingState.idle,
          playing: false,
          updatePosition: Duration.zero,
          bufferedPosition: Duration.zero,
          queueIndex: 0,
        ),
      );
    } catch (e, stack) {
      _logger.severe('Error clearing playback queue', e, stack);
      rethrow;
    }
  }

  // Queue management
  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    try {
      _logger.info('Adding ${mediaItems.length} items to queue');

      // Add items with per-item error handling
      final audioSources = <AudioSource>[];
      final validMediaItems = <MediaItem>[];

      for (final item in mediaItems) {
        try {
          final source = _createAudioSource(item);
          audioSources.add(source);
          validMediaItems.add(item);
          _logger.fine('Successfully created source for: ${item.title}');
        } catch (e) {
          _logger.warning(
            'Failed to create audio source for ${item.title}: $e',
          );
          // Continue with other items instead of failing completely
        }
      }

      if (audioSources.isEmpty) {
        _logger.warning(
          'No valid audio sources could be created from ${mediaItems.length} items',
        );
        return;
      }

      // Add to audio sources
      await _playlist.addAll(audioSources);

      // Update queue with valid items only
      final newQueue = [..._mediaItemQueue.value, ...validMediaItems];
      _mediaItemQueue.add(newQueue);
      queue.add(newQueue);

      // Force update current media item
      await _updateCurrentMediaItem();
      _logger.info(
        'Successfully added ${audioSources.length}/${mediaItems.length} items to queue',
      );
    } catch (e, stack) {
      _logger.severe('Error adding queue items', e, stack);
    }
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _mediaItemQueue.value.length) return;

    final newQueue = List<MediaItem>.from(_mediaItemQueue.value)
      ..removeAt(index);
    _mediaItemQueue.add(newQueue);
    await _playlist.removeAt(index);
    await _saveQueueState();
  }

  // Additional controls
  Future<void> setShuffleMode(AudioServiceShuffleMode mode) async {
    try {
      final enabled = mode == AudioServiceShuffleMode.all;
      if (enabled) {
        await _player.shuffle();
      }
      playbackState.add(playbackState.value.copyWith(shuffleMode: mode));
      await _player.setShuffleModeEnabled(enabled);
    } catch (e, stack) {
      _logger.severe('Error setting shuffle mode', e, stack);
    }
  }

  Future<void> setSleepTimer(int minutes) async {
    try {
      _sleepTimer?.cancel();
      _fadeOutTimer?.cancel();

      if (minutes <= 0) {
        _sleepTimerEnabled.add(false);
        _sleepTimerRemaining.add(null);
        return;
      }

      _sleepTimerEnabled.add(true);
      final endTime = DateTime.now().add(Duration(minutes: minutes));

      // Update remaining time every second
      _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final remaining = endTime.difference(DateTime.now());
        if (remaining.isNegative) {
          timer.cancel();
          _startFadeOut();
        } else {
          _sleepTimerRemaining.add(remaining);
        }
      });
    } catch (e, stack) {
      _logger.severe('Error setting sleep timer', e, stack);
    }
  }

  void _startFadeOut() async {
    try {
      if (!_player.playing) return;

      final startVolume = _volume.value;
      final steps = 30; // Number of volume steps for fade out
      final stepDuration = _fadeOutDuration.inMilliseconds ~/ steps;
      final volumeStep = startVolume / steps;

      var currentVolume = startVolume;
      _fadeOutTimer = Timer.periodic(Duration(milliseconds: stepDuration), (
        timer,
      ) async {
        currentVolume -= volumeStep;
        if (currentVolume <= 0) {
          timer.cancel();
          await pause();
          await setVolume(startVolume); // Restore volume
          _sleepTimerEnabled.add(false);
          _sleepTimerRemaining.add(null);
        } else {
          await setVolume(currentVolume);
        }
      });
    } catch (e, stack) {
      _logger.severe('Error in fade out', e, stack);
    }
  }

  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    try {
      playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
      await _player.setLoopMode(LoopMode.values[repeatMode.index]);
    } catch (e, stack) {
      _logger.severe('Error setting repeat mode', e, stack);
    }
  }

  Future<void> initializeEqualizer() async {
    try {
      _equalizer = AndroidEqualizer();
      if (_equalizer == null) return;

      // Create default equalizer bands
      final equalizerBands = List.generate(
        5,
        (index) => EqualizerBand(
          centerFrequency:
              [60, 230, 910, 3600, 14000][index], // Standard frequencies
          gain: 0.0,
          index: index,
        ),
      );

      final params = EqualizerParameters(
        bands: equalizerBands,
        minDecibels: -15.0,
        maxDecibels: 15.0,
      );

      await _equalizer!.setEnabled(true);
      _equalizerEnabled.add(true);
      _equalizerParams.add(params);
    } catch (e, stack) {
      _logger.severe('Error initializing equalizer', e, stack);
    }
  }

  Future<void> setEqualizer(bool enabled) async {
    try {
      if (_equalizer == null) {
        await initializeEqualizer();
        if (_equalizer == null) return;
      }

      await _equalizer!.setEnabled(enabled);
      _equalizerEnabled.add(enabled);

      if (enabled && !_equalizerParams.hasValue) {
        await initializeEqualizer();
      }
    } catch (e, stack) {
      _logger.severe('Error setting equalizer state', e, stack);
    }
  }

  Future<void> setEqualizerBand(int bandIndex, double gain) async {
    try {
      if (_equalizer == null || !_equalizerParams.hasValue) return;

      final params = _equalizerParams.value;
      if (bandIndex < 0 || bandIndex >= params.bands.length) return;

      final currentGains = params.bands.map((b) => b.gain).toList();
      currentGains[bandIndex] = gain;

      // Update equalizer parameters
      final newBands = List.generate(
        params.bands.length,
        (i) => EqualizerBand(
          centerFrequency: params.bands[i].centerFrequency,
          gain: currentGains[i],
          index: i,
        ),
      );

      await _equalizer!.setEnabled(true);

      _equalizerParams.add(params.copyWith(bands: newBands));
    } catch (e, stack) {
      _logger.severe('Error setting equalizer band', e, stack);
    }
  }

  // Stream getters
  Stream<Duration> get position => _player.positionStream;
  Stream<Duration?> get duration => _player.durationStream;
  Stream<bool> get equalizerEnabled => _equalizerEnabled.stream;
  Stream<EqualizerParameters> get equalizerParams => _equalizerParams.stream;
  Stream<double> get volume => _volume.stream;
  Stream<double> get speed => _speed.stream;
  Stream<bool> get sleepTimerEnabled => _sleepTimerEnabled.stream;
  Stream<Duration?> get sleepTimerRemaining => _sleepTimerRemaining.stream;

  // Helper methods
  AudioSource _createAudioSource(MediaItem mediaItem) {
    final isOffline = mediaItem.extras?['isDownloaded'] as bool? ?? false;
    final localFilePath = mediaItem.extras?['localFilePath'] as String?;
    final url = mediaItem.extras?['url'] as String? ?? mediaItem.id;

    _logger.info(
      'Creating audio source: title=${mediaItem.title}, isOffline=$isOffline, hasLocalPath=${localFilePath != null}, artUri=${mediaItem.artUri}',
    );

    final tag = MediaItem(
      id: mediaItem.id,
      title: mediaItem.title,
      artist: mediaItem.artist,
      album: mediaItem.album,
      displayTitle: mediaItem.displayTitle ?? mediaItem.title,
      displaySubtitle:
          mediaItem.displaySubtitle ??
          mediaItem.artist ??
          mediaItem.extras?['chapterSlug']?.toString(),
      artUri: mediaItem.artUri,
      extras: {
        ...?mediaItem.extras,
        'url': url,
        'artUri': mediaItem.artUri?.toString(),
        'chapterSlug': mediaItem.extras?['chapterSlug'],
        'ebookSlug': mediaItem.extras?['ebookSlug'],
        'isDownloaded': isOffline,
        'localFilePath': localFilePath,
      },
    );

    _logger.info('Audio source tag created with artUri: ${tag.artUri}');

    try {
      // For offline files, use AudioSource.file()
      if (isOffline && localFilePath != null) {
        _logger.info('Using local file source: $localFilePath');
        return AudioSource.file(localFilePath, tag: tag);
      }

      // For online files, use AudioSource.uri()
      final uri = Uri.parse(url);
      _logger.info('Using URI source: $url');
      return AudioSource.uri(uri, tag: tag);
    } catch (e) {
      _logger.severe('Error creating audio source for ${mediaItem.title}: $e');
      // Fallback to URI source if file source fails
      final uri = Uri.parse(url);
      return AudioSource.uri(uri, tag: tag);
    }
  }

  /// Update queue with new list of media items
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    try {
      _logger.info('Updating queue with ${newQueue.length} items');
      // Clear the playlist
      await _playlist.clear();
      _logger.info('Playlist cleared');

      // Create and add audio sources for all items
      if (newQueue.isNotEmpty) {
        final audioSources = <AudioSource>[];
        final validMediaItems = <MediaItem>[];

        for (final item in newQueue) {
          try {
            final source = _createAudioSource(item);
            audioSources.add(source);
            validMediaItems.add(item);
            _logger.fine('Created audio source for: ${item.title}');
          } catch (e) {
            _logger.warning(
              'Failed to create audio source for ${item.title}: $e',
            );
          }
        }

        if (audioSources.isNotEmpty) {
          // Add all audio sources to the playlist
          _logger.info(
            'Adding ${audioSources.length} audio sources to playlist',
          );
          await _playlist.addAll(audioSources);
          _logger.info('Audio sources added to playlist');

          // Small delay to ensure playlist is ready
          await Future.delayed(const Duration(milliseconds: 100));

          // Update the media item queue with valid items
          _mediaItemQueue.add(validMediaItems);
          queue.add(validMediaItems);
          _logger.info('Queue metadata updated');
        } else {
          _logger.warning('No valid audio sources could be created');
          _mediaItemQueue.add([]);
          queue.add([]);
          mediaItem.add(null);
        }
      } else {
        // Empty queue
        _mediaItemQueue.add([]);
        queue.add([]);
        mediaItem.add(null);
      }

      _logger.info('Queue updated successfully');
    } catch (e, stack) {
      _logger.severe('Error updating queue', e, stack);
      rethrow;
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'sleepTimer':
        final minutes = extras?['minutes'] as int?;
        if (minutes != null) await setSleepTimer(minutes);
        break;
      case 'setEqualizer':
        final enabled = extras?['enabled'] as bool?;
        if (enabled != null) await setEqualizer(enabled);
        break;
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  // Clean up resources
  Future<void> dispose() async {
    try {
      _sleepTimer?.cancel();
      _fadeOutTimer?.cancel();
      await _player.dispose();
      await _equalizerEnabled.close();
      await _equalizerParams.close();
      await _volume.close();
      await _speed.close();
      await _mediaItemQueue.close();
      _logger.info('AudioPlayerHandler disposed successfully');
    } catch (e, stack) {
      _logger.severe('Error disposing AudioPlayerHandler', e, stack);
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed);
      _speed.add(speed);
      playbackState.add(playbackState.value.copyWith(speed: speed));
    } catch (e, stack) {
      _logger.severe('Error setting speed', e, stack);
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume.add(volume);
      await _player.setVolume(volume);
    } catch (e, stack) {
      _logger.severe('Error setting volume', e, stack);
    }
  }
}
