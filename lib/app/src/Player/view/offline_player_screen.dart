import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_service/audio_service.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/src/Player/services/music_player_service.dart';
import 'package:path_provider/path_provider.dart';

class OfflinePlayerScreen extends StatefulWidget {
  const OfflinePlayerScreen({super.key});

  static const String routeName = '/offline-player';

  @override
  State<OfflinePlayerScreen> createState() => _OfflinePlayerScreenState();
}

class _OfflinePlayerScreenState extends State<OfflinePlayerScreen> {
  late final MusicPlayerService _playerService;
  bool _isLoading = true;
  List<MediaItem> _offlineTracks = [];

  @override
  void initState() {
    super.initState();
    _playerService = GetIt.I<MusicPlayerService>();
    _loadOfflineTracks();
  }

  Future<void> _loadOfflineTracks() async {
    try {
      final tracks = await _getOfflineAudioFiles();
      if (mounted) {
        setState(() {
          _offlineTracks = tracks;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading offline tracks: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading offline tracks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<MediaItem>> _getOfflineAudioFiles() async {
    final List<MediaItem> mediaItems = [];
    try {
      // Get the app's documents directory for downloaded files
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/audio_downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      await for (final entity in downloadDir.list()) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          final fileName = entity.path.split('/').last;
          mediaItems.add(
            MediaItem(
              id: entity.path,
              album: 'Offline Audio',
              title: fileName.replaceAll('.mp3', ''),
              artUri: Uri.parse('asset:///assets/icons/book.png'),
              extras: {
                'url': entity.path,
                'isDownloaded': true,
                'localFilePath': entity.path,
              },
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error scanning offline files: $e');
    }
    return mediaItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Offline Audio',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _offlineTracks.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.music_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No offline audio files found',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _offlineTracks.length,
                itemBuilder: (context, index) {
                  final track = _offlineTracks[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () {
                        _playerService.playOfflinePlaylist(
                          _offlineTracks,
                          initialIndex: index,
                        );
                      },
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: primaryColor,
                        ),
                      ),
                      title: Text(
                        track.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: StreamBuilder<MediaItem?>(
                        stream: _playerService.currentTrack,
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data?.id == track.id;
                          return Icon(
                            isPlaying ? Icons.volume_up : Icons.play_arrow,
                            color: isPlaying ? primaryColor : Colors.grey,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
