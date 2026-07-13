// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:audio_service/audio_service.dart';
// import 'package:haqvox/app/src/Player/models/recent_play_model.dart';
// import 'package:haqvox/app/src/Player/services/music_player_service.dart';
// import 'package:haqvox/app/src/Player/services/recent_plays_service.dart';

// class RecentPlaysWidget extends StatefulWidget {
//   const RecentPlaysWidget({Key? key}) : super(key: key);

//   @override
//   State<RecentPlaysWidget> createState() => _RecentPlaysWidgetState();
// }

// class _RecentPlaysWidgetState extends State<RecentPlaysWidget> {
//   final recentPlaysService = GetIt.I<RecentPlaysService>();
//   final playerService = GetIt.I<MusicPlayerService>();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<RecentPlay>>(
//       stream: recentPlaysService.watchRecentPlays(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
//           return const SizedBox.shrink();
//         }

//         final allRecentPlays = snapshot.data!;

//         // Remove duplicates by comparing titles
//         final uniqueRecentPlays = allRecentPlays.fold<List<RecentPlay>>([], (
//           unique,
//           play,
//         ) {
//           if (!unique.any((u) => u.title == play.title)) {
//             unique.add(play);
//           }
//           return unique;
//         });

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 'Recently Played',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[800],
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 72, // Adjusted height for the modern compact look
//               child: ListView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 scrollDirection: Axis.horizontal,
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: uniqueRecentPlays.length,
//                 itemBuilder: (context, index) {
//                   final recentPlay = uniqueRecentPlays[index];
//                   return _RecentPlayCard(
//                     recentPlay: recentPlay,
//                     showMiniPlayer: true,
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _RecentPlayCard extends StatelessWidget {
//   final RecentPlay recentPlay;
//   final bool showMiniPlayer;

//   const _RecentPlayCard({
//     Key? key,
//     required this.recentPlay,
//     this.showMiniPlayer = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final playerService = GetIt.I<MusicPlayerService>();

//     return Container(
//       width: 200,
//       margin: const EdgeInsets.only(right: 12),
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.grey.withOpacity(.3),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: () async {
//             final mediaItem = recentPlay.toMediaItem();
//             try {
//               debugPrint(
//                 'Playing recent track: ${mediaItem.title}, chapter: ${mediaItem.artist}, image: ${mediaItem.artUri}',
//               );

//               // Create a playlist with just this track
//               final playlist = [mediaItem];

//               // Use playOfflinePlaylist to ensure proper metadata handling
//               await playerService.playOfflinePlaylist(playlist);

//               // The mini player will automatically show up since we're using
//               // the proper playback method and including all metadata
//             } catch (e) {
//               debugPrint('Error playing recent track: $e');
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Could not play track: ${e.toString()}'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//           child: Row(
//             children: [
//               Container(
//                 height: 56,
//                 width: 56,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Stack(
//                     children: [
//                       Positioned.fill(
//                         child:
//                             recentPlay.artUri != null
//                                 ? Image.network(
//                                   recentPlay.artUri.toString(),
//                                   fit: BoxFit.cover,
//                                   errorBuilder:
//                                       (context, error, stackTrace) => Container(
//                                         color: Theme.of(
//                                           context,
//                                         ).primaryColor.withOpacity(0.1),
//                                         child: Icon(
//                                           Icons.music_note,
//                                           size: 24,
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                       ),
//                                 )
//                                 : Container(
//                                   color: Theme.of(
//                                     context,
//                                   ).primaryColor.withOpacity(0.1),
//                                   child: Icon(
//                                     Icons.music_note,
//                                     size: 24,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                 ),
//                       ),
//                       Positioned.fill(
//                         child: StreamBuilder<MediaItem?>(
//                           stream: playerService.currentTrack,
//                           builder: (context, snapshot) {
//                             final isCurrentTrack =
//                                 snapshot.data?.id == recentPlay.audioUrl;
//                             return Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.4),
//                                   ],
//                                 ),
//                               ),
//                               child: StreamBuilder<PlaybackState>(
//                                 stream: playerService.playbackState,
//                                 builder: (context, playbackSnapshot) {
//                                   final isPlaying =
//                                       isCurrentTrack &&
//                                       (playbackSnapshot.data?.playing ?? false);
//                                   return Center(
//                                     child: Icon(
//                                       isPlaying
//                                           ? Icons.pause_rounded
//                                           : Icons.play_arrow_rounded,
//                                       size: 28,
//                                       color: Colors.white,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       recentPlay.title,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                         color: Colors.grey[800],
//                         letterSpacing: -0.2,
//                       ),
//                     ),
//                     if (recentPlay.artist != null) ...[
//                       const SizedBox(height: 2),
//                       Text(
//                         recentPlay.artist!,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 12,
//                           letterSpacing: -0.1,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
