import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/music_player_service.dart';
import 'modern_player_screen.dart';

class ModernMiniPlayer extends StatelessWidget {
  const ModernMiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerService = GetIt.I<MusicPlayerService>();

    return StreamBuilder<MediaItem?>(
      stream: playerService.currentTrack,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox();

        final bool isOfflineTrack = mediaItem.extras?['isDownloaded'] == true;

        return Dismissible(
          key: const Key('miniplayer'),
          direction: DismissDirection.vertical,
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.down) {
              // Stop playback when dismissing downward
              await playerService.stop();
              return true;
            } else {
              final queue = await playerService.queue.first;
              final currentIndex = queue.indexOf(mediaItem);

              if (!context.mounted) return false;

              // Use a fade transition for smoother navigation
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          ModernPlayerScreen(
                            playlist: queue,
                            initialIndex: currentIndex >= 0 ? currentIndex : 0,
                          ),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
              return false;
            }
          },
          child: Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Bar
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: StreamBuilder<Duration>(
                    stream: playerService.position,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      return StreamBuilder<Duration?>(
                        stream: playerService.duration,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration.zero;
                          if (duration == Duration.zero) {
                            return const SizedBox(height: 2);
                          }
                          return LinearProgressIndicator(
                            value:
                                position.inMilliseconds /
                                duration.inMilliseconds,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                            minHeight: 2,
                          );
                        },
                      );
                    },
                  ),
                ),
                // Player Controls
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Hero(
                    tag: 'album-art',
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
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
                                color: Theme.of(context).primaryColor,
                              )
                              : null,
                    ),
                  ),
                  title: Text(
                    mediaItem.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    mediaItem.artist ?? 'Unknown Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOfflineTrack)
                        const Icon(
                          Icons.download_done,
                          size: 20,
                          color: Colors.green,
                        ),
                      const SizedBox(width: 8),
                      StreamBuilder<PlaybackState>(
                        stream: playerService.playbackState,
                        builder: (context, snapshot) {
                          final playing = snapshot.data?.playing ?? false;
                          return IconButton(
                            icon: Icon(
                              playing ? Icons.pause : Icons.play_arrow,
                            ),
                            onPressed: () {
                              if (playing) {
                                playerService.pause();
                              } else {
                                playerService.play();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
