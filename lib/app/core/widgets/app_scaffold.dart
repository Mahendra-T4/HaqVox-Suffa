// import 'package:flutter/material.dart';
// import 'package:haqvox/app/src/Player/widgets/modern_mini_player.dart';
// import 'package:haqvox/app/src/Player/widgets/offline_mini_player.dart';


// class AppScaffold extends StatelessWidget {
//   final Widget child;
//   final String currentRoute;

//   const AppScaffold({
//     super.key,
//     required this.child,
//     required this.currentRoute,
//   });

//   bool get _shouldShowMiniPlayer {
//     // List of routes where mini player should NOT appear
//     final excludedRoutes = [
//       '/login',
//       '/register',
//       '/set_password',
//       '/verification',
//       '/forgot_password',
//       '/profile',
//       '/edit_profile',
//       '/notifications',
//       '/faq',
//       // Add any other routes where you don't want the mini player
//     ];

//     return !excludedRoutes.contains(currentRoute);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Main content
//           Positioned.fill(
//             child: child,
//           ),

//           // Mini players at the bottom
//           if (_shouldShowMiniPlayer)
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   // Online mini player
//                   ModernMiniPlayer(),
//                   // Offline mini player
//                   OfflineMiniPlayer(),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
