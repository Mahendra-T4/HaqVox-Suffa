// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/Player/services/music_player_service.dart';
import 'package:haqvox/app/src/downloads/services/download_manager.dart';
import 'package:haqvox/app/src/eBook/bloc/e_book_bloc.dart';
import 'package:haqvox/app/src/eBook/view/widget/add_myspace_button.dart';
import 'package:haqvox/app/src/myspace/bloc/my_space_bloc.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';

class EBookChapterAudio extends StatefulWidget {
  final AudioParams audioParams;
  const EBookChapterAudio({super.key, required this.audioParams});

  static const String routeName = '/eBook-chapter-audio';

  @override
  State<EBookChapterAudio> createState() => _EBookChapterAudioState();
}

class _EBookChapterAudioState extends State<EBookChapterAudio>
    with WidgetsBindingObserver {
  late final EBookBloc _eBookBloc;
  late final MySpaceBloc _mySpaceBloc;
  late final MusicPlayerService _playerService;
  StreamSubscription? _playbackStateSubscription;
  int? currentPlayingIndex;
  bool isPlaying = false;
  // String? uKey;
  // String? uSubscriptionKey;
  final DownloadManager _downloadManager = DownloadManager();
  bool _disposed = false;

  // Add these new variables for progress tracking
  final Map<String, double> _downloadProgress = {};
  Timer? _progressUpdateTimer;

  // void initUser() async {
  //   if (_disposed) return;
  //   try {
  //     // StorageConfig config = StorageConfig();
  //     // final userKey = await config.getUserData(key: DBKeys.userKey);
  //     // final subscription = await config.getUserData(
  //     //   key: DBKeys.uSubscriptionKey,
  //     // );
  //     if (mounted) {
  //       setState(() {
  //         uKey = userKey;
  //         uSubscriptionKey = subscription;
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Error initializing user: $e');
  //     // if (mounted) {
  //     //   ScaffoldMessenger.of(context).showSnackBar(
  //     //     SnackBar(
  //     //       content: Text('Error loading user data: $e'),
  //     //       backgroundColor: Colors.red,
  //     //     ),
  //     //   );
  //     // }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (_disposed) return;

    try {
      WidgetsBinding.instance.addObserver(this);
      _eBookBloc = EBookBloc();
      _mySpaceBloc =
          MySpaceBloc(); // Get player service with error handling and initialization check
      try {
        _playerService = GetIt.I<MusicPlayerService>();

        // Wait for service to initialize with timeout
        for (int i = 0; i < 10; i++) {
          if (_playerService.isInitialized) {
            break;
          }
          if (i == 9) {
            throw Exception(
              'Audio service initialization timeout after 5 seconds',
            );
          }
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        debugPrint('Error getting or initializing MusicPlayerService: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error initializing audio service: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => _initializePlayer(),
              ),
            ),
          );
        }
        return;
      }

      _setupPlaybackListener();

      _eBookBloc.add(
        EBookChapterAudioFetchingEvent(
          chapterSlug: widget.audioParams.chapterSlug,
          ebookSlug: widget.audioParams.ebookSlug,
        ),
      );

      // initUser(); // No need to await as it updates UI independently

      debugPrint('Player initialization completed successfully');
    } catch (e, stack) {
      debugPrint('Error in _initializePlayer: $e\n$stack');
      if (mounted) {
        _showPlaybackError(
          context,
          'Error initializing audio player: ${e.toString()}',
        );
      }
    }
  }

  void _setupPlaybackListener() {
    _playbackStateSubscription?.cancel();

    // Listen to playback state changes
    _playbackStateSubscription = _playerService.playbackState.listen(
      (state) {
        if (_disposed) return;
        if (mounted) {
          setState(() {
            isPlaying = state.playing;
          });
        }
      },
      onError: (error) {
        debugPrint('Playback state error: $error');
        if (mounted) {
          _showPlaybackError(context, 'Playback error: $error');
        }
      },
    );

    // Also listen to currentTrack changes
    _playerService.currentTrack.listen(
      (mediaItem) {
        if (_disposed || !mounted || mediaItem == null) return;
        debugPrint(
          'Current track updated: title=${mediaItem.title}, chapter=${mediaItem.artist}, image=${mediaItem.artUri}',
        );
        debugPrint('Track extras: ${mediaItem.extras}');
      },
      onError: (error) {
        debugPrint('Current track error: $error');
        if (mounted) {
          _showPlaybackError(context, 'Track error: $error');
        }
      },
    );
  }

  void _showPlaybackError(BuildContext context, String message) {
    debugPrint('Playback error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            _initializePlayer();
          },
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App going to background
      _progressUpdateTimer?.cancel();
      // Save any necessary state
    } else if (state == AppLifecycleState.resumed) {
      if (mounted) {
        _startProgressUpdates();
        // Verify audio service is still working
        _verifyAudioService();
      }
    }
  }

  Future<void> _verifyAudioService() async {
    try {
      if (!_playerService.isInitialized) {
        debugPrint(
          'Audio service not initialized after resume, reinitializing...',
        );
        await _initializePlayer();
      }
    } catch (e) {
      debugPrint('Error verifying audio service: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we were playing when returning to the page
    _playerService.playbackState.first.then((state) {
      if (mounted && !_disposed) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    try {
      _disposed = true;

      // Clean up resources in a safe order
      _progressUpdateTimer?.cancel();
      _playbackStateSubscription?.cancel();

      // Don't stop playback when leaving the page
      // Only clean up UI-related resources

      // Clean up blocs
      _eBookBloc.close();
      _mySpaceBloc.close();

      // Dispose download manager resources but keep downloads
      _downloadManager.dispose();

      WidgetsBinding.instance.removeObserver(this);
    } catch (e) {
      debugPrint('Error during dispose: $e');
    } finally {
      super.dispose();
    }
  }

  void _startProgressUpdates() {
    _progressUpdateTimer?.cancel();
    if (_disposed) return;

    _progressUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (_disposed || !mounted) {
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

  Future<List<MediaItem>> _createPlaylist(List<dynamic> audioList) async {
    List<MediaItem> playlist = [];
    int validItemCount = 0;
    int failedItemCount = 0;

    for (var audio in audioList) {
      try {
        if (audio == null) {
          failedItemCount++;
          continue;
        }

        final audioPath = audio.audioPath?.toString();
        final audioSlug = audio.audioSlug?.toString();
        final audioName = audio.audioName?.toString();

        if (audioPath == null || audioSlug == null || audioName == null) {
          debugPrint('Invalid audio item: missing required fields');
          failedItemCount++;
          continue;
        }

        bool isDownloaded = false;
        String? localPath;

        try {
          isDownloaded = await _downloadManager.isDownloaded(audioPath);
          if (isDownloaded) {
            localPath = await _downloadManager.getLocalPath(audioPath);
            if (localPath == null) {
              debugPrint(
                'Warning: Downloaded file path not found for $audioPath',
              );
              isDownloaded = false; // Reset if we can't find the local file
            }
          }
        } catch (e) {
          debugPrint('Error checking download status: $e');
          // Continue with streaming URL if download check fails
        }

        // Ensure we have a valid image URL or fallback
        final String imageUrl =
            widget.audioParams.image?.isNotEmpty == true
                ? widget.audioParams.image!
                : 'asset:///assets/icons/book.png';
        final artUri = Uri.parse(imageUrl);

        // Create MediaItem with full metadata
        final mediaItem = MediaItem(
          id: audioSlug,
          album: widget.audioParams.chapterTitle, // Use chapter title as album
          title: audioName,
          artist:
              widget.audioParams.chapterTitle, // Use chapter title as artist
          artUri: artUri,
          displayTitle: audioName,
          displaySubtitle: widget.audioParams.chapterTitle,
          extras: {
            'url': audioPath,
            'isDownloaded': isDownloaded,
            'localFilePath': localPath,
            'chapterSlug': widget.audioParams.chapterSlug,
            'ebookSlug': widget.audioParams.ebookSlug,
            'audioSlug': audioSlug,
            'artUri': imageUrl, // Include image URL in extras
            'coverUrl': imageUrl, // Include as coverUrl too for compatibility
            'chapter': widget.audioParams.chapterTitle, // Include chapter name
            'chapterTitle':
                widget.audioParams.chapterTitle, // Include as chapterTitle too
          },
        );

        debugPrint(
          'Creating MediaItem: title=${mediaItem.title}, chapter=${mediaItem.artist}, image=${mediaItem.artUri}',
        );
        playlist.add(mediaItem);
        validItemCount++;
      } catch (e) {
        debugPrint('Error creating MediaItem: $e');
        failedItemCount++;
      }
    }

    if (validItemCount == 0) {
      throw Exception('No valid audio items could be created for the playlist');
    }

    if (failedItemCount > 0) {
      debugPrint('Warning: Failed to create $failedItemCount audio items');
    }

    return playlist;
  }

  Future<void> _playAudio(
    List<dynamic> audioList, [
    int initialIndex = 0,
  ]) async {
    if (_disposed || !mounted) return;

    try {
      if (audioList.isEmpty) {
        throw Exception('No audio files available to play');
      }

      // Ensure audio service is properly initialized
      debugPrint('Starting audio playback initialization...');

      // Create playlist before updating UI state
      debugPrint('Creating playlist from audio list...');
      List<MediaItem> playlist;
      try {
        playlist = await _createPlaylist(audioList);
      } catch (e) {
        debugPrint('Error creating playlist: $e');
        _showPlaybackError(context, 'Error preparing playlist: $e');
        return;
      }

      if (playlist.isEmpty) {
        _showPlaybackError(
          context,
          'No valid audio tracks found in the playlist',
        );
        return;
      }

      if (_disposed || !mounted) return;

      // Safety check for index
      if (initialIndex < 0 || initialIndex >= playlist.length) {
        debugPrint('Invalid initial index: $initialIndex, resetting to 0');
        initialIndex = 0;
      }

      debugPrint('Playing track ${initialIndex + 1}/${playlist.length}');
      final trackToPlay = playlist[initialIndex];
      debugPrint(
        'Track details: title=${trackToPlay.title}, chapter=${trackToPlay.artist}, image=${trackToPlay.artUri}',
      );

      try {
        // Stop any current playback first
        await _playerService.stop();

        // Add a small delay to ensure clean state
        await Future.delayed(const Duration(milliseconds: 100));

        // Start playback with new playlist
        await _playerService.playOfflinePlaylist(
          playlist,
          initialIndex: initialIndex,
        );

        debugPrint('Playback started successfully');
      } catch (e) {
        debugPrint('Error during playback operation: $e');
        _showPlaybackError(
          context,
          'Error starting playback. Please try again.',
        );
        return;
      }
    } catch (e, stack) {
      debugPrint('Error in _playAudio: $e\n$stack');
      if (mounted) {
        _showPlaybackError(
          context,
          'Error preparing audio: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }

  Future<void> _downloadAudio(String url, String fileName, String title) async {
    if (_disposed || !mounted) return;

    try {
      _startProgressUpdates();

      final filePath = await _downloadManager.downloadAudio(
        url: url,
        fileName: fileName,
        title: title,
        artist: widget.audioParams.chapterTitle,
        chapterTitle: widget.audioParams.chapterTitle,
        chapterSlug: widget.audioParams.chapterSlug,
        ebookSlug: widget.audioParams.ebookSlug,
        ebookTitle: widget.audioParams.ebookTitle,
        coverUrl: widget.audioParams.image,
      );

      if (_disposed || !mounted) return;

      setState(() {
        _downloadProgress.remove(url);
      });

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error downloading audio: $e');
      if (_disposed || !mounted) return;

      setState(() {
        _downloadProgress.remove(url);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading audio: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _downloadAudio(url, fileName, title),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Allow navigation without stopping playback
        return true;
      },
      child: StreamBuilder(
        stream: InternetConnectionService().connectionStream,
        initialData: true, // Assume connected initially
        builder: (context, snapshot) {
          // Handle error state
          if (snapshot.hasError) {
            return const OfflineDownloads();
          }

          // Handle disconnected state
          if (snapshot.data == false) {
            return const OfflineDownloads();
          }

          // Handle loading state
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            appBar: customAppBar(
              title: widget.audioParams.chapterTitle,
              context: context,
            ),
            body: BlocListener<MySpaceBloc, MySpaceState>(
              bloc: _mySpaceBloc,
              listener: (context, state) {
                if (state is AddMySpaceLoadedSuccessState &&
                    state.mySpaceType == '2') {
                  final result = state.addOnMySpaceEntity;
                  final isDuplicate =
                      result.message?.toLowerCase().contains('already added') ??
                      false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isDuplicate
                            ? 'This audio is already in My Space.'
                            : result.message ?? 'Unable to update My Space.',
                      ),
                      backgroundColor:
                          isDuplicate
                              ? Colors.blueGrey
                              : result.status == 1
                              ? Colors.green
                              : Colors.red,
                    ),
                  );
                } else if (state is AddMySpaceFailedErrorState &&
                    state.mySpaceType == '2') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: BlocConsumer<EBookBloc, EBookState>(
                bloc: _eBookBloc,
                listener: (context, state) {
                  // Handle state changes but don't affect playback
                },
                builder: (context, state) {
                  if (state is EBookLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  } else if (state is EBookChapterAudioLoadedSuccessState) {
                    final successState = state.chapterAudioEntity;
                    return Column(
                      children: [
                        // Header with image
                        Container(
                          height: 200,
                          width: double.infinity,
                          color: primaryColor.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child:
                                      widget.audioParams.image != ''
                                          ? Image.network(
                                            widget.audioParams.image.toString(),
                                            fit: BoxFit.cover,
                                          )
                                          : Image.asset(
                                            Assets.defaulteBookCover,
                                            fit: BoxFit.cover,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.audioParams.chapterTitle,
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${successState.record?.length ?? 0} Audio Lessons',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Play All button
                        if (successState.record != null &&
                            successState.record!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                              onPressed: () => _playAudio(successState.record!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Play All',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Audio list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: successState.record?.length ?? 0,
                            itemBuilder: (context, index) {
                              final audio = successState.record![index];
                              return StreamBuilder<MediaItem?>(
                                stream: _playerService.currentTrack,
                                builder: (context, currentTrackSnapshot) {
                                  final currentTrack =
                                      currentTrackSnapshot.data;
                                  final isCurrent =
                                      currentTrack != null &&
                                      currentTrack.id == audio.audioSlug;
                                  return StreamBuilder<PlaybackState>(
                                    stream: _playerService.playbackState,
                                    builder: (context, playbackSnapshot) {
                                      final isPlaying =
                                          playbackSnapshot.data?.playing ??
                                          false;
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: ListTile(
                                            onTap: () {
                                              if (HiveService.getSubscription()
                                                      .toString() ==
                                                  '1') {
                                                _mySpaceBloc.add(
                                                  AddOnMySpaceEvent(
                                                    audioSlug:
                                                        successState
                                                            .record![index]
                                                            .audioSlug
                                                            .toString(),
                                                    mySpaceType: '1',
                                                    context: context,
                                                  ),
                                                );
                                              }
                                              _playAudio(
                                                successState.record!,
                                                index,
                                              );
                                            },
                                            // contentPadding:
                                            //     const EdgeInsets.fromLTRB(16, 12, 8, 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            leading: SizedBox(
                                              height: 48,
                                              width: 48,

                                              child: IconButton(
                                                icon: Icon(
                                                  isCurrent && isPlaying
                                                      ? Icons
                                                          .pause_circle_filled
                                                      : Icons.play_circle_fill,
                                                  color: primaryColor,
                                                  size: 35,
                                                ),
                                                onPressed: () async {
                                                  if (isCurrent && isPlaying) {
                                                    await _playerService
                                                        .pause();
                                                  } else {
                                                    await _playAudio(
                                                      successState.record!,
                                                      index,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            title: Text(
                                              audio.audioName.toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                widget.audioParams.chapterTitle,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                            trailing:
                                                HiveService.getUserId() != null
                                                    ? Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        AddMySpaceButton(
                                                          audioSlug:
                                                              audio.audioSlug
                                                                  .toString(),
                                                          mySpaceType: '2',
                                                          audioBookmarked:
                                                              audio
                                                                  .audioBookmarked!,
                                                          successCallback: () {
                                                            _eBookBloc.add(
                                                              EBookChapterAudioFetchingEvent(
                                                                chapterSlug:
                                                                    widget
                                                                        .audioParams
                                                                        .chapterSlug,
                                                                ebookSlug:
                                                                    widget
                                                                        .audioParams
                                                                        .ebookSlug,
                                                              ),
                                                            );
                                                          },
                                                        ),

                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        FutureBuilder<bool>(
                                                          future: _downloadManager
                                                              .isDownloaded(
                                                                audio.audioPath
                                                                    .toString(),
                                                              ),
                                                          builder: (
                                                            context,
                                                            snapshot,
                                                          ) {
                                                            final bool
                                                            isDownloaded =
                                                                snapshot.data ??
                                                                false;
                                                            final bool
                                                            isDownloading =
                                                                _downloadManager
                                                                    .isDownloading(
                                                                      audio
                                                                          .audioPath
                                                                          .toString(),
                                                                    );

                                                            return Material(
                                                              color:
                                                                  Colors
                                                                      .transparent,
                                                              child:
                                                                  isDownloading
                                                                      ? Stack(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        children: [
                                                                          StreamBuilder<
                                                                            double
                                                                          >(
                                                                            stream: _downloadManager.getDownloadProgressStream(
                                                                              audio.audioPath.toString(),
                                                                            ),
                                                                            builder: (
                                                                              context,
                                                                              snapshot,
                                                                            ) {
                                                                              final progress =
                                                                                  snapshot.data ??
                                                                                  0.0;
                                                                              return SizedBox(
                                                                                width:
                                                                                    24,
                                                                                height:
                                                                                    24,
                                                                                child: CircularProgressIndicator(
                                                                                  value:
                                                                                      progress,
                                                                                  strokeWidth:
                                                                                      2,
                                                                                  color:
                                                                                      primaryColor,
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                          IconButton(
                                                                            icon: Icon(
                                                                              Icons.cancel,
                                                                              color:
                                                                                  Colors.red,
                                                                              size:
                                                                                  18,
                                                                            ),
                                                                            padding:
                                                                                EdgeInsets.zero,
                                                                            constraints:
                                                                                BoxConstraints(),
                                                                            onPressed: () {
                                                                              _downloadManager.cancelDownload(
                                                                                audio.audioPath.toString(),
                                                                              );
                                                                            },
                                                                            tooltip:
                                                                                'Cancel Download',
                                                                          ),
                                                                        ],
                                                                      )
                                                                      : InkWell(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              50,
                                                                            ),
                                                                        onTap:
                                                                            isDownloaded
                                                                                ? null
                                                                                : () {
                                                                                  _downloadAudio(
                                                                                    audio.audioPath.toString(),
                                                                                    '${audio.audioSlug}_${audio.audioName}.mp3',
                                                                                    audio.audioName.toString(),
                                                                                  ).then(
                                                                                    (
                                                                                      _,
                                                                                    ) {
                                                                                      _mySpaceBloc.add(
                                                                                        AddOnMySpaceEvent(
                                                                                          audioSlug:
                                                                                              successState.record![index].audioSlug.toString(),
                                                                                          mySpaceType:
                                                                                              '3',
                                                                                          context:
                                                                                              context,
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                },
                                                                        child: Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(
                                                                                8,
                                                                              ),
                                                                          child: Icon(
                                                                            isDownloaded
                                                                                ? Icons.download_done_rounded
                                                                                : Icons.download_rounded,
                                                                            color:
                                                                                isDownloaded
                                                                                    ? Colors.green
                                                                                    : primaryColor,
                                                                            size:
                                                                                24,
                                                                          ),
                                                                        ),
                                                                      ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    )
                                                    : Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Material(
                                                          color:
                                                              Colors
                                                                  .transparent,
                                                          child: InkWell(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  50,
                                                                ),
                                                            onTap: () {
                                                              CustomSnackBar.show(
                                                                context:
                                                                    context,
                                                                message:
                                                                    'Please log in to bookmark this audio.',
                                                                type:
                                                                    SnackBarType
                                                                        .warning,
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    8,
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .bookmark_outline_rounded,
                                                                color:
                                                                    primaryColor,
                                                                size: 24,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Material(
                                                          color:
                                                              Colors
                                                                  .transparent,
                                                          child: InkWell(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  50,
                                                                ),
                                                            onTap: () {
                                                              CustomSnackBar.show(
                                                                context:
                                                                    context,
                                                                message:
                                                                    'Please log in to download this audio.',
                                                                type:
                                                                    SnackBarType
                                                                        .warning,
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    8,
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .download_rounded,
                                                                color:
                                                                    primaryColor,
                                                                size: 24,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is EBookChapterAudioFailedToLoadErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.error,
                            style: GoogleFonts.poppins(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _eBookBloc.add(
                                EBookChapterAudioFetchingEvent(
                                  chapterSlug: widget.audioParams.chapterSlug,
                                  ebookSlug: widget.audioParams.ebookSlug,
                                ),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('Something went wrong'));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class AudioParams {
  final String chapterTitle;
  final String chapterSlug;
  final String ebookSlug;
  final String ebookTitle;
  final String? image;
  final String? audioSlug;
  final int? bookmarkStatus;

  AudioParams({
    required this.chapterTitle,
    required this.chapterSlug,
    required this.ebookSlug,
    required this.ebookTitle,
    this.image,
    this.audioSlug,
    this.bookmarkStatus,
  });
}
