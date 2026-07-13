import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:haqvox/app.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/dependency_injection/di.dart';
import 'package:haqvox/app/core/database/hive_database.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/eBook/models/ebook_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:haqvox/app/src/Player/services/audio_player_handler.dart';
import 'package:haqvox/app/src/auth/bloc/auth_bloc.dart';
import 'package:haqvox/app/src/global/bloc/global_bloc.dart';
import 'package:haqvox/app/src/home/bloc/home_bloc.dart';
import 'package:haqvox/app/src/myspace/bloc/my_space_bloc.dart';
import 'package:haqvox/app/src/support/bloc/ticket_bloc.dart';
import 'package:haqvox/app/src/Player/services/music_player_service.dart';
import 'package:haqvox/app/src/Player/models/media_item_adapter.dart';
import 'package:haqvox/app/src/Player/services/recent_plays_service.dart';
import 'package:haqvox/app/src/downloads/database/downloads_hive_db.dart';

// Audio handler instance that will be initialized in background and used across the app

late AudioHandler audioHandler;

//! Signin Apk Key - DXT2EWN4W7ISSAAAAAAAAAAAAA - play console

void main() async {
  try {
    await runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        await HiveService.init();
        InternetConnectionService().startMonitoring();

        // CRITICAL: Only do bare minimum before runApp()
        setupDI();
        await dotenv.load(fileName: ".env"); // Quick operation

        // Initialize RecentPlaysService early (lightweight)
        try {
          final recentPlaysService = RecentPlaysService();
          await recentPlaysService.init();
          GetIt.I.registerSingleton<RecentPlaysService>(recentPlaysService);
        } catch (e) {
          debugPrint('RecentPlaysService init error: $e');
        }

        // Register stub MusicPlayerService before runApp() so widgets don't crash
        // It will be properly initialized in background
        GetIt.I.registerSingleton<MusicPlayerService>(
          MusicPlayerService(AudioPlayerHandler()),
        );

        // Enable verbose logging
        Logger.root.level = Level.ALL;
        Logger.root.onRecord.listen((record) {
          debugPrint('${record.level.name}: ${record.time}: ${record.message}');
          if (record.error != null) {
            debugPrint('Error: ${record.error}\n${record.stackTrace}');
          }
        });

        // Run the app first - users see UI immediately
        runApp(
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => AuthBloc()),
              BlocProvider(create: (context) => GlobalBloc()),
              BlocProvider(create: (context) => HomeBloc()),
              BlocProvider(create: (context) => MySpaceBloc()),
              BlocProvider(create: (context) => TicketBloc()),
            ],
            child: const App(),
          ),
        );

        // Initialize heavy services in background (doesn't block UI)
        _initializeBackgroundServices();
      },
      (error, stack) {
        debugPrint('Uncaught error in app: $error\n$stack');
      },
    );
  } catch (e, stack) {
    debugPrint('Fatal error during app initialization: $e\n$stack');
    // Show error screen instead of crashing
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Error initializing app: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

/// Initialize heavy services without blocking the UI
Future<void> _initializeBackgroundServices() async {
  try {
    // Initialize Hive Database Manager with specific path
    final appDir = await getApplicationDocumentsDirectory();
    final hivePath = path.join(appDir.path, 'hive');
    await HiveDatabase().init(hivePath: hivePath);

    // Register additional adapters for other services (not managed by HiveDatabase)
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(MediaItemAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(EBookRecordAdapter());
    }

    // Initialize downloads database (uses box from HiveDatabase)
    await DownloadsDatabase.init();

    // Configure audio session
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );

    // Note: MobileAds initialization is handled by AdsService.initialize()
    // called from HomeBuilder when the home screen loads.
    // Do NOT initialize MobileAds here to avoid race conditions.

    // Initialize audio service after a short delay
    await Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        debugPrint('Initializing AudioHandler...');
        final initializedHandler = await AudioService.init(
          builder: () => AudioPlayerHandler(),
          config: const AudioServiceConfig(
            androidNotificationChannelId: 'com.tfourtech.haqvox.audio',
            androidNotificationChannelName: 'Audio playback',
            androidNotificationIcon: 'drawable/notification_icon',
            androidShowNotificationBadge: true,
            notificationColor: Colors.blue,
            androidStopForegroundOnPause: false,
            fastForwardInterval: Duration(seconds: 10),
            rewindInterval: Duration(seconds: 10),
          ),
        ).timeout(const Duration(seconds: 5));

        audioHandler = initializedHandler;
        debugPrint('AudioHandler initialized successfully');

        // Initialize MusicPlayerService
        final playerService = MusicPlayerService(initializedHandler);

        // Wait for service initialization
        bool serviceReady = false;
        for (int i = 0; i < 10; i++) {
          if (playerService.isInitialized) {
            serviceReady = true;
            break;
          }
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (serviceReady) {
          // Replace stub MusicPlayerService with real one
          GetIt.I.unregister<MusicPlayerService>();
          GetIt.I.registerSingleton<MusicPlayerService>(playerService);
          debugPrint('MusicPlayerService updated successfully');
        }
      } catch (e, stack) {
        debugPrint('Failed to initialize audio services: $e\n$stack');
        // Create fallback handler
        audioHandler = AudioPlayerHandler();
        debugPrint('Using fallback AudioHandler');
      }
    });
  } catch (e, stack) {
    debugPrint('Background initialization error: $e\n$stack');
  }
}
