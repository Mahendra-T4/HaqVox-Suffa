import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:io';
import 'package:filesize/filesize.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/src/Player/services/music_player_service.dart';
import 'package:haqvox/app/core/database/hive_models/downloaded_audio_model.dart';
import 'package:haqvox/app/src/downloads/services/download_manager.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

class DownloadsTab extends StatefulWidget {
  const DownloadsTab({Key? key}) : super(key: key);

  @override
  State<DownloadsTab> createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab> {
  final DownloadManager _downloadManager = DownloadManager();
  final _playerService = GetIt.I<MusicPlayerService>();
  bool _isGridView = false;
  String _sortBy = 'date'; // 'date', 'name', 'size'
  bool _sortAscending = false;

  Future<void> _refreshDownloads() async {
    setState(() {});
  }

  List<DownloadedAudioModel> _sortDownloads(
    List<DownloadedAudioModel> downloads,
  ) {
    switch (_sortBy) {
      case 'date':
        downloads.sort(
          (a, b) =>
              _sortAscending
                  ? a.downloadDate.compareTo(b.downloadDate)
                  : b.downloadDate.compareTo(a.downloadDate),
        );
        break;
      case 'name':
        downloads.sort(
          (a, b) =>
              _sortAscending
                  ? a.title.compareTo(b.title)
                  : b.title.compareTo(a.title),
        );
        break;
      case 'size':
        downloads.sort(
          (a, b) =>
              _sortAscending
                  ? a.fileSize.compareTo(b.fileSize)
                  : b.fileSize.compareTo(a.fileSize),
        );
        break;
    }
    return downloads;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStorageInfo(),
        _buildControlBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshDownloads,
            color: primaryColor,
            child: FutureBuilder<List<DownloadedAudioModel>>(
              future: _downloadManager.getAllDownloads(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading downloads: ${snapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  );
                }

                final downloads = _sortDownloads(snapshot.data ?? []);

                if (downloads.isEmpty) {
                  return _buildEmptyState();
                }

                return _isGridView
                    ? _buildGridView(downloads)
                    : _buildListView(downloads);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.sort),
            items: [
              DropdownMenuItem(
                value: 'date',
                child: Text('Sort by Date', style: GoogleFonts.poppins()),
              ),
              DropdownMenuItem(
                value: 'name',
                child: Text('Sort by Name', style: GoogleFonts.poppins()),
              ),
              DropdownMenuItem(
                value: 'size',
                child: Text('Sort by Size', style: GoogleFonts.poppins()),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sortBy = value;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
          ),
          TextButton.icon(
            onPressed: _showDeleteAllDialog,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: Text(
              'Clear all',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Clear Downloads',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Delete all downloaded audio files? This action cannot be undone.',
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
                  'Delete all',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _downloadManager.deleteAllDownloads();
      if (mounted) setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not clear downloads: $error')),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_done_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No downloads yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your downloaded audio will appear here',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<DownloadedAudioModel> downloads) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: () => _playAudio(download),
            borderRadius: BorderRadius.circular(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    image:
                        download.coverUrl != null
                            ? DecorationImage(
                              image: NetworkImage(download.coverUrl!),
                              fit: BoxFit.cover,
                            )
                            : null,
                    color: primaryColor.withValues(alpha: 0.1),
                  ),
                  child:
                      download.coverUrl == null
                          ? Icon(
                            Icons.music_note,
                            size: 48,
                            color: primaryColor,
                          )
                          : null,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        download.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        filesize(download.fileSize),
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
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

  Widget _buildListView(List<DownloadedAudioModel> downloads) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
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
          child: ListTile(
            onTap: () => _playAudio(download),
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                image:
                    download.coverUrl != null
                        ? DecorationImage(
                          image: NetworkImage(download.coverUrl!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  download.coverUrl == null
                      ? Icon(Icons.music_note, color: primaryColor)
                      : null,
            ),
            title: Text(
              download.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  download.artist,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      filesize(download.fileSize),
                      style: GoogleFonts.poppins(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM d, y').format(download.downloadDate),
                      style: GoogleFonts.poppins(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_outline),
                        title: Text('Play', style: GoogleFonts.poppins()),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () => _playAudio(download),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        title: Text(
                          'Delete',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () => _deleteDownload(download),
                    ),
                  ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStorageInfo() {
    return FutureBuilder<int>(
      future: _downloadManager.getTotalDownloadSize(),
      builder: (context, snapshot) {
        final size =
            snapshot.hasData ? filesize(snapshot.data) : 'Calculating...';
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.storage, color: primaryColor),
              const SizedBox(width: 12),
              Text(
                'Storage used: $size',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _playAudio(DownloadedAudioModel download) async {
    try {
      // Verify file exists
      final file = File(download.localPath);
      if (!await file.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Audio file not found. The download may be corrupted.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Audio file appears to be empty. Please try downloading again.',
            ),
            // backgroundColor
          ),
        );
        return;
      }

      // Create MediaItem with local file path for offline playback
      final mediaItem = MediaItem(
        id: download.id,
        title: download.title,
        artist: download.artist,
        artUri: Uri.parse(
          download.coverUrl ?? 'asset:///assets/icons/book.png',
        ),
        album: 'Offline Audio',
        displayTitle: download.title,
        displaySubtitle: download.artist,
        extras: {
          'url': download.url,
          'isDownloaded': true,
          'localFilePath': download.localPath,
          'chapterSlug': download.chapterSlug,
          'ebookSlug': download.ebookSlug,
        },
      );

      // Use offline playback for downloaded files
      await _playerService.playOfflinePlaylist([mediaItem], initialIndex: 0);
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: $e'),
          backgroundColor: Colors.red,
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
      try {
        await _downloadManager.deleteDownload(download.url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download deleted', style: GoogleFonts.poppins()),
            ),
          );
          setState(() {}); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error deleting download: $e',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
