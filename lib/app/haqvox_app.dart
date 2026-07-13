// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../app/src/auth/bloc/auth_bloc.dart';
// import '../app/src/global/bloc/global_bloc.dart';
// import '../app/src/home/bloc/home_bloc.dart';
// import '../app/src/myspace/bloc/my_space_bloc.dart';
// import '../app/core/router/router_config.dart';

// class HaqVoxApp extends StatelessWidget {
//   const HaqVoxApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => AuthBloc()),
//         BlocProvider(create: (context) => GlobalBloc()),
//         BlocProvider(create: (context) => HomeBloc()),
//         BlocProvider(create: (context) => MySpaceBloc()),
//       ],
//       child: MaterialApp.router(
//         debugShowCheckedModeBanner: false,
//         routerConfig: router,
//         builder: (context, child) {
//           return FutureBuilder<bool>(
//             future: _checkAndRequestPermissions(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const MaterialApp(
//                   home: Scaffold(
//                     body: Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//                 );
//               }

//               if (snapshot.data == false) {
//                 return MaterialApp(
//                   home: Scaffold(
//                     body: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Permissions Required',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'This app needs access to storage and notifications\n'
//                             'to play audio and show player controls.',
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 24),
//                           ElevatedButton(
//                             onPressed: () async {
//                               final granted = await _checkAndRequestPermissions();
//                               if (!granted) {
//                                 openAppSettings();
//                               }
//                             },
//                             child: const Text('Grant Permissions'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }

//               return child ?? const SizedBox.shrink();
//             },
//           );
//         },
//       ),
//     );
//   }

//   Future<bool> _checkAndRequestPermissions() async {
//     final permissions = [
//       Permission.notification,
//       Permission.storage,
//       Permission.audio,
//     ];

//     // Check current status
//     final statuses = await Future.wait(
//       permissions.map((permission) => permission.status),
//     );

//     // If all permissions are granted, return true
//     if (statuses.every((status) => status.isGranted)) {
//       return true;
//     }

//     // Request permissions
//     final results = await permissions.request();

//     // Return true only if all permissions are granted
//     return results.values.every((status) => status.isGranted);
//   }
// }
