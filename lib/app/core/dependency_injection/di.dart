import 'package:get_it/get_it.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/core/database/hive_database.dart';
import 'package:haqvox/app/core/database/repositories/user_repository.dart';
import 'package:haqvox/app/core/database/repositories/recent_play_repository.dart';
import 'package:haqvox/app/core/database/repositories/bookmark_repository.dart';
import 'package:haqvox/app/core/database/repositories/download_repository.dart';
import 'package:haqvox/app/core/database/repositories/support_ticket_repository.dart';
import 'package:haqvox/app/core/database/repositories/notification_repository.dart';
import 'package:haqvox/app/core/database/repositories/app_settings_repository.dart';

GetIt di = GetIt.instance;

Future<void> setupDI() async {
  // Initialize Hive Database first
  final hiveDb = HiveDatabase();
  await hiveDb.init();
  di.registerSingleton<HiveDatabase>(hiveDb);

  // Register all repositories as singletons
  di.registerSingleton<UserRepository>(UserRepository());
  di.registerSingleton<RecentPlayRepository>(RecentPlayRepository());
  di.registerSingleton<BookmarkRepository>(BookmarkRepository());
  di.registerSingleton<DownloadRepository>(DownloadRepository());
  di.registerSingleton<SupportTicketRepository>(SupportTicketRepository());
  di.registerSingleton<NotificationRepository>(NotificationRepository());
  di.registerSingleton<AppSettingsRepository>(AppSettingsRepository());

  // Register other services
  // di.registerSingleton(InternetConnectionHelper());

  print('✅ Dependency Injection setup completed');
}
