import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import '../services/music_player_service.dart';
import '../models/track_model.dart';

class PositionData {
  final Duration position;
  final Duration duration;

  PositionData({required this.position, required this.duration});
}

class ModernPlayerScreen extends StatefulWidget {
  final List<MediaItem> playlist;
  final int initialIndex;

  const ModernPlayerScreen({
    Key? key,
    required this.playlist,
    this.initialIndex = 0,
  }) : super(key: key);

  static const routeName = '/modern_player';

  @override
  _ModernPlayerScreenState createState() => _ModernPlayerScreenState();
}

class _ModernPlayerScreenState extends State<ModernPlayerScreen>
    with SingleTickerProviderStateMixin {
  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  void _changeSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _playerService.setSpeed(speed);
  }

  late final MusicPlayerService _playerService;
  late final AnimationController _artworkController;

  @override
  void initState() {
    super.initState();
    _playerService = GetIt.I<MusicPlayerService>();
    _artworkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _playerService.currentTrack.first.then((currentTrack) {
      if (currentTrack == null) {
        // Only initialize playback if there's no current track
        final tracks =
            widget.playlist
                .map(
                  (item) => Track(
                    id: item.id,
                    title: item.title,
                    artist: item.artist ?? '',
                    album: item.album ?? '',
                    url: item.extras?['url'] ?? item.id,
                    artworkUrl: item.artUri?.toString(),
                    duration: item.duration,
                  ),
                )
                .toList();

        _playerService.playTracks(tracks, initialIndex: widget.initialIndex);
      }
    });
  }

  @override
  void dispose() {
    _artworkController.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest2<Duration, Duration?, PositionData>(
        _playerService.position,
        _playerService.duration,
        (position, duration) => PositionData(
          position: position,
          duration: duration ?? Duration.zero,
        ),
      );

  Future<void> _handleRepeatMode() async {
    final playbackState = await _playerService.playbackState.first;
    final currentMode = playbackState.repeatMode;

    final modes = [
      AudioServiceRepeatMode.none,
      AudioServiceRepeatMode.one,
      AudioServiceRepeatMode.all,
    ];
    final nextIndex = (modes.indexOf(currentMode) + 1) % modes.length;
    _playerService.setRepeatMode(modes[nextIndex]);
  }

  Future<void> _handleShuffleMode() async {
    final playbackState = await _playerService.playbackState.first;
    final currentMode = playbackState.shuffleMode;

    _playerService.setShuffleMode(
      currentMode == AudioServiceShuffleMode.none
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.expand_more),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: PopupMenuButton<double>(
              initialValue: _playbackSpeed,

              tooltip: 'Playback speed',
              onSelected: _changeSpeed,
              itemBuilder:
                  (context) =>
                      _speedOptions
                          .map(
                            (speed) => PopupMenuItem<double>(
                              value: speed,
                              child: Text(
                                '${speed}x',
                                style: TextStyle(
                                  fontWeight:
                                      speed == _playbackSpeed
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.speed, color: Theme.of(context).primaryColor),
                  Text(
                    '${_playbackSpeed}x',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: StreamBuilder<MediaItem?>(
        stream: _playerService.currentTrack,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          if (mediaItem == null) return const SizedBox();

          final bool isOfflineTrack = mediaItem.extras?['isDownloaded'] == true;

          return Column(
            children: [
              // Artwork and info section
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.2),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: kToolbarHeight + 32),
                      // Album artwork
                      Hero(
                        tag: 'album-art',
                        child: Container(
                          width: 280,
                          height: 280,
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            image:
                                mediaItem.artUri != null
                                    ? DecorationImage(
                                      image: NetworkImage(
                                        mediaItem.artUri.toString(),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              mediaItem.artUri == null
                                  ? Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Theme.of(context).primaryColor,
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Track info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            Text(
                              mediaItem.title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mediaItem.artist ?? 'Unknown Artist',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            if (isOfflineTrack) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.download_done,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Available Offline',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Playback controls section
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bar
                    StreamBuilder<PositionData>(
                      stream: _positionDataStream,
                      builder: (context, snapshot) {
                        final positionData =
                            snapshot.data ??
                            PositionData(
                              position: Duration.zero,
                              duration: Duration.zero,
                            );
                        return Column(
                          children: [
                            Slider(
                              value:
                                  positionData.position.inMilliseconds
                                      .toDouble(),
                              max:
                                  positionData.duration.inMilliseconds
                                      .toDouble(),
                              onChanged: (value) {
                                _playerService.seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(positionData.position)),
                                  Text(_formatDuration(positionData.duration)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Playback controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: StreamBuilder<PlaybackState>(
                            stream: _playerService.playbackState,
                            builder: (context, snapshot) {
                              final repeatMode =
                                  snapshot.data?.repeatMode ??
                                  AudioServiceRepeatMode.none;
                              final icons = {
                                AudioServiceRepeatMode.none:
                                    Icons.repeat_outlined,
                                AudioServiceRepeatMode.one: Icons.repeat_one,
                                AudioServiceRepeatMode.all: Icons.repeat,
                              };
                              return Icon(
                                icons[repeatMode] ?? Icons.repeat_outlined,
                                color:
                                    repeatMode != AudioServiceRepeatMode.none
                                        ? Theme.of(context).primaryColor
                                        : null,
                              );
                            },
                          ),
                          onPressed: _handleRepeatMode,
                        ),
                        StreamBuilder<List<MediaItem>>(
                          stream: _playerService.queue,
                          builder: (context, queueSnapshot) {
                            return StreamBuilder<MediaItem?>(
                              stream: _playerService.currentTrack,
                              builder: (context, trackSnapshot) {
                                final queue = queueSnapshot.data ?? [];
                                final currentTrack = trackSnapshot.data;

                                // Find current track index
                                int currentIndex = 0;
                                if (currentTrack != null && queue.isNotEmpty) {
                                  currentIndex = queue.indexWhere(
                                    (item) => item.id == currentTrack.id,
                                  );
                                  if (currentIndex == -1) currentIndex = 0;
                                }

                                // Disable previous button if on first track
                                final canSkipPrevious = currentIndex > 0;

                                return IconButton(
                                  icon: const Icon(Icons.skip_previous),
                                  iconSize: 36,
                                  onPressed:
                                      canSkipPrevious
                                          ? _playerService.skipToPrevious
                                          : null,
                                  color:
                                      canSkipPrevious
                                          ? Theme.of(context).iconTheme.color
                                          : Colors.grey,
                                );
                              },
                            );
                          },
                        ),

                        // Playback speed control
                        StreamBuilder<PlaybackState>(
                          stream: _playerService.playbackState,
                          builder: (context, snapshot) {
                            final playing = snapshot.data?.playing ?? false;
                            return IconButton(
                              icon: Icon(
                                playing ? Icons.pause : Icons.play_arrow,
                              ),
                              iconSize: 48,
                              onPressed: () {
                                if (playing) {
                                  _playerService.pause();
                                } else {
                                  _playerService.play();
                                }
                              },
                            );
                          },
                        ),
                        StreamBuilder<List<MediaItem>>(
                          stream: _playerService.queue,
                          builder: (context, queueSnapshot) {
                            return StreamBuilder<MediaItem?>(
                              stream: _playerService.currentTrack,
                              builder: (context, trackSnapshot) {
                                final queue = queueSnapshot.data ?? [];
                                final currentTrack = trackSnapshot.data;

                                // Find current track index
                                int currentIndex = 0;
                                if (currentTrack != null && queue.isNotEmpty) {
                                  currentIndex = queue.indexWhere(
                                    (item) => item.id == currentTrack.id,
                                  );
                                  if (currentIndex == -1) currentIndex = 0;
                                }

                                // Disable next button if on last track
                                final canSkipNext =
                                    currentIndex < queue.length - 1;

                                return IconButton(
                                  icon: const Icon(Icons.skip_next),
                                  iconSize: 36,
                                  onPressed:
                                      canSkipNext
                                          ? _playerService.skipToNext
                                          : null,
                                  color:
                                      canSkipNext
                                          ? Theme.of(context).iconTheme.color
                                          : Colors.grey,
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: StreamBuilder<PlaybackState>(
                            stream: _playerService.playbackState,
                            builder: (context, snapshot) {
                              final shuffleMode =
                                  snapshot.data?.shuffleMode ??
                                  AudioServiceShuffleMode.none;
                              return Icon(
                                Icons.shuffle,
                                color:
                                    shuffleMode == AudioServiceShuffleMode.all
                                        ? Theme.of(context).primaryColor
                                        : null,
                              );
                            },
                          ),
                          onPressed: _handleShuffleMode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
