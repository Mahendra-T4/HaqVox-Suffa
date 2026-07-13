import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/src/Player/widgets/modern_player_screen.dart';
import 'package:haqvox/app/src/downloads/services/download_manager.dart';
import 'package:haqvox/app/src/myspace/bloc/my_space_bloc.dart';
import 'package:haqvox/app/src/myspace/models/myspace_list_entity.dart';

class RecentPlay extends StatefulWidget {
  final int? index;
  const RecentPlay({super.key, this.index});

  @override
  State<RecentPlay> createState() => _RecentPlayState();
}

class _RecentPlayState extends State<RecentPlay> {
  late MySpaceBloc _mySpaceBloc;
  final DownloadManager _downloadManager = DownloadManager();
  List<MediaItem> playlist = [];
  // Unused download progress tracking - kept for potential future use
  // Map<String, double> _downloadProgress = {};
  Timer? _progressUpdateTimer;

  // Unused progress update method - kept for potential future use
  // void _startProgressUpdates() {
  //   _progressUpdateTimer?.cancel();
  //   _progressUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (
  //     timer,
  //   ) {
  //     if (!mounted) {
  //       timer.cancel();
  //       return;
  //     }
  //     setState(() {
  //       // Update progress for all downloading files
  //       for (var url in _downloadManager.getDownloadingFiles()) {
  //         _downloadProgress[url] = _downloadManager.getProgress(url);
  //       }
  //     });
  //   });
  // }

  // Unused download method - kept for potential future use
  // Future<void> _downloadAudio(MediaItem mediaItem) async {
  //   try {
  //     _startProgressUpdates();
  //
  //     final filePath = await _downloadManager.downloadAudio(
  //       url: mediaItem.extras!['url'] as String,
  //       fileName:
  //           '${DateTime.now().millisecondsSinceEpoch}_${mediaItem.title}.mp3',
  //       title: mediaItem.title,
  //       artist: mediaItem.artist ?? 'Suffa Audio',
  //       coverUrl:
  //           mediaItem.artUri?.toString() ?? 'asset:///' + Assets.bookIconImage,
  //       chapterTitle: mediaItem.album ?? 'My Space Collection',
  //       chapterSlug: 'myspace',
  //       ebookSlug: 'myspace',
  //     );
  //
  //     if (!mounted) return;
  //
  //     if (filePath != null) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text('Download completed')));
  //       setState(() {
  //         _downloadProgress.remove(mediaItem.extras!['url'] as String);
  //       });
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() {
  //       _downloadProgress.remove(mediaItem.extras!['url'] as String);
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error downloading audio: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<MediaItem> _createAudioTrack(RecordSpace record) async {
    final bool isDownloaded = await _downloadManager.isDownloaded(
      record.audioPath.toString(),
    );

    String? localFilePath;
    if (isDownloaded) {
      localFilePath = await _downloadManager.getLocalPath(
        record.audioPath.toString(),
      );
    }

    return MediaItem(
      id: record.mySpaceKey ?? DateTime.now().toString(),
      title: record.audioName.toString(),
      artist: 'Suffa Audio',
      album: 'My Space Collection',
      artUri: Uri.parse('asset:///' + Assets.bookIconImage),
      extras: {
        'url': record.audioPath.toString(),
        'isDownloaded': isDownloaded,
        'localFilePath': localFilePath,
      },
    );
  }

  @override
  void initState() {
    _mySpaceBloc = MySpaceBloc();
    _mySpaceBloc.add(
      FetchMySpaceListFromServerEvent(mySpaceType: '1', context: context),
    );
    super.initState();
  }

  @override
  void dispose() {
    _progressUpdateTimer?.cancel();
    _mySpaceBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Plays',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: BlocConsumer<MySpaceBloc, MySpaceState>(
            bloc: _mySpaceBloc,
            listener: (context, state) {
              if (state is MySpaceListFailedErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              switch (state.runtimeType) {
                case MySpaceLoadingState:
                  return const Center(child: CircularProgressIndicator());
                case MySpaceListLoadedSuccessState:
                  final mySpaceList = (state as MySpaceListLoadedSuccessState)
                      .mySpaceListEntity;
                  return mySpaceList.status == 1
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: mySpaceList.record!.length,
                          itemBuilder: (context, index) {
                            final record = mySpaceList.record![index];
                            return Container(
                              width: 260,
                              margin: EdgeInsets.only(
                                right: 12,
                                left: index == 0 ? 0 : 0,
                              ),
                              child: Material(
                                elevation: 2,
                                shadowColor: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.withOpacity(.3),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () async {
                                    final audioTrack = await _createAudioTrack(
                                      record,
                                    );
                                    playlist.clear();
                                    playlist.add(audioTrack);

                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ModernPlayerScreen(
                                                playlist: playlist,
                                                initialIndex: 0,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              const Icon(
                                                Icons.audio_file,
                                                color: primaryColor,
                                                size: 30,
                                              ),
                                              Positioned(
                                                right: 4,
                                                bottom: 4,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                record.audioName.toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                record.mySpaceDate.toString(),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_note,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No recent plays',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                default:
                  return const Center(child: Text('No data available'));
              }
            },
          ),
        ),
      ],
    );
  }
}
