import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/constant/colors.dart';
import 'package:haqvox/app/src/Player/services/music_player_service.dart';

class OfflineMiniPlayer extends StatefulWidget {
  const OfflineMiniPlayer({super.key});

  @override
  State<OfflineMiniPlayer> createState() => _OfflineMiniPlayerState();
}

class _OfflineMiniPlayerState extends State<OfflineMiniPlayer> {
  bool _isClosed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final playerService = GetIt.I<MusicPlayerService>();
    playerService.currentTrack.listen((mediaItem) {
      if (mediaItem != null && _isClosed) {
        setState(() {
          _isClosed = false;
        });
      }
    });
  }

  DecorationImage? _buildTrackImage(MediaItem mediaItem) {
    try {
      debugPrint(
        'Building track image for: ${mediaItem.title}, artUri: ${mediaItem.artUri}, extras: ${mediaItem.extras}',
      );

      // Check if this is a MySpace track
      final isMySpaceTrack = mediaItem.extras?['isMySpace'] == true;
      if (isMySpaceTrack) {
        debugPrint('Using MySpace default image for track');
        return DecorationImage(
          image: AssetImage(Assets.mySpaceMusicDefaultImage),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            debugPrint('Error loading MySpace default image: $exception');
          },
        );
      }

      // For non-MySpace tracks, use the normal image logic
      String? imageUrl = mediaItem.extras?['artUri'] as String?;

      // Fall back to artUri from the MediaItem if not in extras
      if (imageUrl == null && mediaItem.artUri != null) {
        imageUrl = mediaItem.artUri.toString();
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        debugPrint('No image URL found for track, using default');
        // Use default offline music image
        return DecorationImage(
          image: AssetImage('assets/icons/book.png'),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            debugPrint('Error loading default offline image: $exception');
          },
        );
      }

      debugPrint('Using image URL: $imageUrl');

      ImageProvider imageProvider;
      // Check for asset:// URIs (2 slashes)
      if (imageUrl.startsWith('asset://')) {
        String assetPath = imageUrl.replaceFirst('asset://', '');
        debugPrint('Loading asset image: $assetPath');
        imageProvider = AssetImage(assetPath);
      }
      // Check for network URLs
      else if (imageUrl.startsWith('http://') ||
          imageUrl.startsWith('https://')) {
        debugPrint('Loading network image: $imageUrl');
        imageProvider = NetworkImage(imageUrl);
      }
      // If it doesn't look like a URL and not an asset, treat as asset path
      else {
        debugPrint('Loading as asset image: $imageUrl');
        imageProvider = AssetImage(imageUrl);
      }

      return DecorationImage(
        image: imageProvider,
        fit: BoxFit.cover,
        onError: (exception, stackTrace) {
          debugPrint('Error loading image: $exception');
        },
      );
    } catch (e) {
      debugPrint('Error building track image: $e');
      // Fallback to default image on error
      return DecorationImage(
        image: AssetImage('assets/icons/book.png'),
        fit: BoxFit.cover,
        onError: (exception, stackTrace) {
          debugPrint('Error loading fallback image: $exception');
        },
      );
    }
  }

  String _getDisplayTitle(MediaItem mediaItem) {
    return mediaItem.title;
  }

  String _getDisplaySubtitle(MediaItem mediaItem) {
    return mediaItem.displaySubtitle ??
        mediaItem.extras?['chapter']?.toString() ??
        mediaItem.extras?['chapterSlug']?.toString() ??
        mediaItem.artist ??
        'Unknown Chapter';
  }

  @override
  Widget build(BuildContext context) {
    late final MusicPlayerService playerService;
    try {
      playerService = GetIt.I<MusicPlayerService>();
      if (!playerService.isInitialized) {
        debugPrint('MusicPlayerService not initialized yet');
        return const SizedBox.shrink();
      }
    } catch (e) {
      debugPrint('Error getting MusicPlayerService: $e');
      return const SizedBox.shrink();
    }

    if (ModalRoute.of(context)?.settings.name == '/player') {
      return const SizedBox.shrink();
    }

    return StreamBuilder<MediaItem?>(
      stream: playerService.currentTrack.handleError((error) {
        debugPrint('Error in currentTrack stream: $error');
        return null;
      }),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Error in mini player: ${snapshot.error}');
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || _isClosed) return const SizedBox.shrink();

        final mediaItem = snapshot.data!;

        return Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: _buildTrackImage(mediaItem),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayTitle(mediaItem),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getDisplaySubtitle(mediaItem),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StreamBuilder<PlaybackState>(
                stream: playerService.playbackState.handleError((error) {
                  debugPrint('Error in playbackState stream: $error');
                  return PlaybackState(
                    processingState: AudioProcessingState.idle,
                    playing: false,
                  );
                }),
                builder: (context, snapshot) {
                  final playbackState = snapshot.data;
                  final playing = playbackState?.playing ?? false;

                  return Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                          color: AppColors.color7,
                        ),
                        onPressed: () {
                          try {
                            if (playing) {
                              playerService.pause();
                            } else {
                              playerService.play();
                            }
                          } catch (e) {
                            debugPrint('Error controlling playback: $e');
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next, color: AppColors.color7),
                        onPressed: () {
                          try {
                            playerService.skipToNext();
                          } catch (e) {
                            debugPrint('Error skipping to next: $e');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () async {
                          await playerService.pause();
                          await playerService.stop();
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
        );
      },
    );
  }
}
