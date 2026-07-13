import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/src/Player/widgets/modern_player_screen.dart';
import 'package:haqvox/app/core/database/hive_models/downloaded_audio_model.dart';

import '../services/download_manager.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final DownloadManager _downloadManager = DownloadManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Downloads',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteAllDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<DownloadedAudioModel>>(
        future: _downloadManager.getAllDownloads(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading downloads',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          final downloads = snapshot.data ?? [];
          if (downloads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download_done_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No downloads yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Group downloads by chapter
          final downloadsByChapter = <String, List<DownloadedAudioModel>>{};
          for (var download in downloads) {
            final list = downloadsByChapter[download.chapterTitle] ?? [];
            list.add(download);
            downloadsByChapter[download.chapterTitle] = list;
          }

          return ListView.builder(
            itemCount: downloadsByChapter.length,
            itemBuilder: (context, index) {
              final chapter = downloadsByChapter.keys.elementAt(index);
              final chapterDownloads = downloadsByChapter[chapter]!;

              return ExpansionTile(
                title: Text(
                  chapter,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                children: [
                  ...chapterDownloads.map(
                    (download) => ListTile(
                      onTap: () => _playAudio(download),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.music_note, color: primaryColor),
                      ),
                      title: Text(
                        download.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        download.artist,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteDownload(download),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _playAudio(DownloadedAudioModel download) async {
    try {
      debugPrint('Playing downloaded audio:');
      debugPrint('Title: ${download.title}');
      debugPrint('Local path: ${download.localPath}');

      // Verify file exists
      final file = File(download.localPath);
      if (!await file.exists()) {
        debugPrint('File not found, removing from database');
        await _downloadManager.deleteDownload(download.url);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio file not found. The entry has been removed.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {});
        return;
      }

      // Verify file size
      final fileSize = await file.length();
      if (fileSize == 0) {
        debugPrint('File is empty, removing from database');
        await _downloadManager.deleteDownload(download.url);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Audio file is corrupted. The entry has been removed.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {});
        return;
      }

      if (!mounted) return;
      final track = MediaItem(
        id: download.id,
        title: download.title,
        artist: download.artist,
        artUri:
            download.coverUrl?.isNotEmpty == true
                ? Uri.parse(download.coverUrl!)
                : null,
        album: 'Suffa Audio',
        extras: {
          'url': download.url,
          'localFilePath': file.absolute.path,
          'isDownloaded': true,
          'audioSlug': download.id,
          'chapterSlug': download.chapterTitle,
        },
      );
      await Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder:
              (context) =>
                  ModernPlayerScreen(playlist: [track], initialIndex: 0),
        ),
      );
    } catch (e, stack) {
      debugPrint('Error preparing audio track: $e');
      debugPrint('Stack trace: $stack');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Delete',
            textColor: Colors.white,
            onPressed: () => _deleteDownload(download),
          ),
        ),
      );
    }
  }

  Future<void> _deleteDownload(DownloadedAudioModel download) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Download',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete this download?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _downloadManager.deleteDownload(download.url);
      setState(() {});
    }
  }

  Future<void> _showDeleteAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete All Downloads',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete all downloads? This action cannot be undone.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete All',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _downloadManager.deleteAllDownloads();
      setState(() {});
    }
  }
}
