// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';

import 'package:get_it/get_it.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/src/Player/services/music_player_service.dart';
import 'package:haqvox/app/src/downloads/services/download_manager.dart';
import 'package:haqvox/app/src/myspace/bloc/my_space_bloc.dart';
import 'package:haqvox/app/src/myspace/models/myspace_list_entity.dart';

class MySpaceListTab extends StatefulWidget {
  final String? mySpaceType;
  final int? index;
  const MySpaceListTab({super.key, this.mySpaceType, this.index});

  @override
  State<MySpaceListTab> createState() => _MySpaceListTabState();
}

class _MySpaceListTabState extends State<MySpaceListTab> {
  late MySpaceBloc _mySpaceBloc;
  final DownloadManager _downloadManager = DownloadManager();
  Map<String, double> _downloadProgress = {};
  Timer? _progressUpdateTimer;

  @override
  void initState() {
    super.initState();
    _mySpaceBloc = MySpaceBloc();
    _mySpaceBloc.add(
      FetchMySpaceListFromServerEvent(
        mySpaceType: widget.mySpaceType.toString(),
        context: context,
      ),
    );
  }

  @override
  void dispose() {
    _progressUpdateTimer?.cancel();
    _mySpaceBloc.close();
    super.dispose();
  }

  void _startProgressUpdates() {
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        // Update progress for all downloading files
        for (var url in _downloadManager.getDownloadingFiles()) {
          _downloadProgress[url] = _downloadManager.getProgress(url);
        }
      });
    });
  }

  // Helper method to check if a track is downloaded
  Future<Map<String, dynamic>> _getDownloadInfo(String? audioPath) async {
    if (audioPath == null || audioPath.isEmpty) {
      return {'isDownloaded': false, 'localFilePath': null};
    }

    final bool isDownloaded = await _downloadManager.isDownloaded(audioPath);
    final String? localFilePath =
        isDownloaded ? await _downloadManager.getLocalPath(audioPath) : null;

    return {'isDownloaded': isDownloaded, 'localFilePath': localFilePath};
  }

  Future<void> _downloadAudio(
    String url,
    String title,
    String imagePath,
  ) async {
    try {
      _startProgressUpdates();

      final filePath = await _downloadManager.downloadAudio(
        url: url,
        fileName: '${DateTime.now().millisecondsSinceEpoch}_$title.mp3',
        title: title,
        artist: 'Suffa Audio',
        coverUrl: imagePath,
        chapterTitle: 'My Space Collection',
        chapterSlug: 'myspace',
        ebookSlug: 'myspace',
        ebookTitle: 'My Space Collection',
      );

      if (!mounted) return;

      if (filePath != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Download completed')));
        setState(() {
          _downloadProgress.remove(url);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _downloadProgress.remove(url);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _playTrack(RecordSpace record) async {
    try {
      // Use MySpace specific default music image
      String? artworkUrl = record.coverImageUrl;
      if (artworkUrl == null || artworkUrl.isEmpty) {
        artworkUrl = record.imageUrl;
      }
      if (artworkUrl == null || artworkUrl.isEmpty) {
        artworkUrl = 'asset:///assets/icons/book.png'; // fallback default
      }

      final downloadInfo = await _getDownloadInfo(record.audioPath);
      final String url =
          (downloadInfo['isDownloaded'] == true &&
                  downloadInfo['localFilePath'] != null)
              ? downloadInfo['localFilePath']!
              : record.audioPath ?? '';

      final mediaItem = MediaItem(
        id: record.mySpaceKey ?? DateTime.now().toString(),
        title: record.audioName ?? 'Unknown Track',
        artist: record.chapterSlug ?? 'Unknown Chapter',
        album: record.ebookSlug ?? 'My Space Collection',
        displayTitle: record.audioName ?? 'Unknown Track',
        displaySubtitle: record.chapterSlug ?? 'Unknown Chapter',
        artUri: Uri.parse(artworkUrl),
        extras: {
          'url': url,
          'chapterSlug': record.chapterSlug,
          'ebookSlug': record.ebookSlug,
          'artUri': artworkUrl,
          'coverUrl': artworkUrl,
          'isDownloaded': downloadInfo['isDownloaded'],
          'localFilePath': downloadInfo['localFilePath'],
          'audioPath': record.audioPath,
          'chapter': record.chapterSlug,
          'chapterTitle': record.chapterSlug,
          'isMySpace': true, // Flag to identify MySpace tracks
        },
      );

      if (!mounted) return;

      debugPrint(
        'Playing MySpace track with metadata: ${mediaItem.title}, chapter: ${mediaItem.artist}, image: ${mediaItem.artUri}',
      );

      final playerService = GetIt.I<MusicPlayerService>();
      await playerService.playOfflinePlaylist([mediaItem]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MySpaceBloc, MySpaceState>(
      bloc: _mySpaceBloc,
      listener: (context, state) {
        if (state is MySpaceListFailedErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        switch (state.runtimeType) {
          case MySpaceLoadingState:
            return const Center(child: CircularProgressIndicator());
          case MySpaceListLoadedSuccessState:
            final mySpaceList =
                (state as MySpaceListLoadedSuccessState).mySpaceListEntity;
            return mySpaceList.status == 1
                ? ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mySpaceList.record!.length,
                  itemBuilder: (context, index) {
                    final record = mySpaceList.record![index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          onTap: () => _playTrack(record),
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                Assets.mySpaceMusicDefaultImage,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.music_note,
                                      color: primaryColor,
                                    ),
                              ),
                            ),
                          ),
                          title: Text(
                            record.audioName.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(record.mySpaceDate.toString()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FutureBuilder<bool>(
                                future: _downloadManager.isDownloaded(
                                  record.audioPath.toString(),
                                ),
                                builder: (context, snapshot) {
                                  final bool isDownloaded =
                                      snapshot.data ?? false;
                                  final bool isDownloading = _downloadProgress
                                      .containsKey(record.audioPath.toString());

                                  if (isDownloading) {
                                    return SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        value:
                                            _downloadProgress[record.audioPath
                                                .toString()],
                                        strokeWidth: 2,
                                        color: primaryColor,
                                      ),
                                    );
                                  } else if (!isDownloaded) {
                                    return IconButton(
                                      icon: const Icon(
                                        Icons.download,
                                        color: primaryColor,
                                      ),
                                      onPressed:
                                          () => _downloadAudio(
                                            record.audioPath.toString(),
                                            record.audioName.toString(),
                                            record.coverImageUrl.toString(),
                                          ),
                                    );
                                  }
                                  return const SizedBox(width: 48);
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  BlocProvider.of<MySpaceBloc>(context).add(
                                    DeleteMySpaceRecordsFromServerEvent(
                                      mySpaceKey: record.mySpaceKey.toString(),
                                      mySpaceType:
                                          widget.mySpaceType.toString(),
                                      context: context,
                                    ),
                                  );
                                  setState(() {
                                    mySpaceList.record!.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
                : Center(child: Text(mySpaceList.message.toString()));
          default:
            return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
