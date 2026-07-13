// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../services/permission_handler.dart';

// class App extends StatelessWidget {
//   const App({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: FutureBuilder<bool>(
//         future: _checkAndRequestPermissions(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           if (snapshot.hasError || snapshot.data == false) {
//             return Scaffold(
//               body: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Permissions are required to use this app',
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: () => openAppSettings(),
//                       child: const Text('Open Settings'),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           return const YourMainApp(); // Replace with your main app widget
//         },
//       ),
//     );
//   }

//   Future<bool> _checkAndRequestPermissions() async {
//     // Check if permissions are already granted
//     final status = await Future.wait([
//       Permission.notification.status,
//       Permission.storage.status,
//       Permission.audio.status,
//     ]);

//     if (status.every((status) => status.isGranted)) {
//       return true;
//     }

//     // Request permissions
//     final results = await [
//       Permission.notification,
//       Permission.storage,
//       Permission.audio,
//     ].request();

//     return results.values.every((status) => status.isGranted);
//   }
// }
