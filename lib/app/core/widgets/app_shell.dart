import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/src/bottom_bar.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../src/Player/services/music_player_service.dart';
import '../../src/Player/widgets/modern_player_screen.dart';

class AppShell extends StatelessWidget {
  final String currentRoute;
  final Widget child;

  const AppShell({Key? key, required this.currentRoute, required this.child})
    : super(key: key);

  bool get _isMainScreen {
    return [BottomBar.routeName].contains(currentRoute);
  }

  bool get _shouldShowMiniPlayer {
    // List of routes where mini player should NOT appear
    final excludedRoutes = [
      '/login',
      '/register',
      '/set_password',
      '/verification',
      '/forgot_password',
      '/profile',
      '/edit_profile',
      '/notifications',
      '/faq',
      OfflineDownloads.routeName,
    ];

    return !excludedRoutes.contains(currentRoute);
  }

  // bool get _isEditProfile {
  //   return [EditProfile.routeName].contains(currentRoute);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(children: [Expanded(child: child)]),
          if (_shouldShowMiniPlayer)
            Positioned(
              bottom:
                  _isMainScreen
                      ? kBottomNavigationBarHeight +
                          MediaQuery.of(context).padding.bottom
                      : MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                bottom: true,
                child: _ModernMiniPlayer(), // Use new stateful widget
              ),
            ),
        ],
      ),
    );
  }
}

class _ModernMiniPlayer extends StatefulWidget {
  @override
  State<_ModernMiniPlayer> createState() => _ModernMiniPlayerState();
}

class _ModernMiniPlayerState extends State<_ModernMiniPlayer> {
  Color? _dominantColor;
  MediaItem? _lastMediaItem;
  bool _isClosed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final playerService = GetIt.I<MusicPlayerService>();
    playerService.currentTrack.listen((mediaItem) {
      if (mediaItem != null) {
        _updateDominantColorIfNeeded(mediaItem);
        if (_isClosed) {
          setState(() {
            _isClosed = false;
          });
        }
      }
    });
  }

  Future<Color> _getDarkColor(Color color) async {
    // Blend with black to darken
    return Color.lerp(color, Colors.black, 0.45) ?? color;
  }

  Future<void> _updateDominantColorIfNeeded(MediaItem mediaItem) async {
    if (_lastMediaItem?.id == mediaItem.id) return;
    _lastMediaItem = mediaItem;
    if (mediaItem.artUri != null &&
        mediaItem.artUri.toString().startsWith('http')) {
      try {
        final palette = await PaletteGenerator.fromImageProvider(
          NetworkImage(mediaItem.artUri.toString()),
          size: const Size(200, 200),
        );
        final baseColor =
            palette.dominantColor?.color ?? Colors.blueGrey.shade900;
        final darkColor = await _getDarkColor(baseColor);
        if (mounted) {
          setState(() {
            _dominantColor = darkColor;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _dominantColor = Colors.blueGrey[900]!;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _dominantColor = Colors.blueGrey[900]!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerService = GetIt.I<MusicPlayerService>();
    return StreamBuilder<MediaItem?>(
      stream: playerService.currentTrack,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null || _isClosed) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () async {
            final queue = await playerService.queue.first;
            final currentIndex = queue.indexOf(mediaItem);
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ModernPlayerScreen(
                      playlist: queue,
                      initialIndex: currentIndex >= 0 ? currentIndex : 0,
                    ),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _dominantColor ?? Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  // Progress bar at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: StreamBuilder<Duration>(
                      stream: playerService.position,
                      builder: (context, posSnapshot) {
                        final position = posSnapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration?>(
                          stream: playerService.duration,
                          builder: (context, durSnapshot) {
                            final duration = durSnapshot.data ?? Duration.zero;
                            if (duration == Duration.zero) {
                              return const SizedBox(height: 2);
                            }
                            return ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: LinearProgressIndicator(
                                  value:
                                      duration.inMilliseconds == 0
                                          ? 0
                                          : position.inMilliseconds /
                                              duration.inMilliseconds,
                                  backgroundColor: Colors.white12,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        primaryColor,
                                      ),
                                  minHeight: 4,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                    child: Row(
                      children: [
                        // Album artwork
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child:
                                mediaItem.artUri != null
                                    ? Image.network(
                                      mediaItem.artUri.toString(),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.music_note,
                                            color: Colors.grey[600],
                                            size: 24,
                                          ),
                                    )
                                    : Icon(
                                      Icons.music_note,
                                      color: Colors.grey[600],
                                      size: 24,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Track info
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                mediaItem.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mediaItem.artist ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Compact controls
                        StreamBuilder<PlaybackState>(
                          stream: playerService.playbackState,
                          builder: (context, snapshot) {
                            final playing = snapshot.data?.playing ?? false;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 48,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          playing
                                              ? playerService.pause()
                                              : playerService.play();
                                        },
                                        child: Icon(
                                          playing
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => playerService.skipToNext(),
                                        child: const Icon(
                                          Icons.skip_next_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Close player',
                                  constraints: const BoxConstraints.tightFor(
                                    width: 40,
                                    height: 40,
                                  ),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    await playerService.clearQueue();
                                    if (!mounted) return;
                                    setState(() {
                                      _isClosed = true;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
