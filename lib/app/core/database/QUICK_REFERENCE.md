# Haqvox Database Architecture - Quick Reference

## What Changed?

✅ **Unified all databases to Hive only**
- Removed: Drift (SQLite)
- Removed: SharedPreferences (except session tokens if needed)
- Kept: Hive (fastest local database for mobile)

---

## Project Structure

```
lib/app/core/database/
├── hive_database.dart                    ⭐ Main database manager
├── hive_models/
│   ├── user_model.dart                   👤 User auth & profile
│   ├── recent_play_model.dart            ▶️  Play history
│   ├── bookmark_model.dart               🔖 Bookmarks
│   ├── downloaded_audio_model.dart       📥 Downloads
│   ├── support_ticket_model.dart         🎟️  Support tickets
│   ├── notification_model.dart           🔔 Notifications
│   ├── app_settings_model.dart           ⚙️  App preferences
│   └── index.dart                        📦 Export all models
├── repositories/
│   ├── user_repository.dart              👤 User operations
│   ├── recent_play_repository.dart       ▶️  Play operations
│   ├── bookmark_repository.dart          🔖 Bookmark operations
│   ├── download_repository.dart          📥 Download operations
│   ├── support_ticket_repository.dart    🎟️  Ticket operations
│   ├── notification_repository.dart      🔔 Notification operations
│   ├── app_settings_repository.dart      ⚙️  Settings operations
│   └── index.dart                        📦 Export all repos
├── dependency_injection/
│   └── di.dart                           🔗 DI setup
└── HIVE_DATABASE_GUIDE.md                📖 Full documentation
```

---

## Quick Start

### 1. Initialize in main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // This initializes HiveDatabase + all repositories
  await setupDI();
  
  runApp(const App());
}
```

### 2. Use in BLoC
```dart
import 'package:get_it/get_it.dart';
import 'package:haqvox/app/core/database/repositories/index.dart';

class MyBloc extends Bloc<MyEvent, MyState> {
  final _userRepo = GetIt.I<UserRepository>();
  final _recentPlayRepo = GetIt.I<RecentPlayRepository>();

  MyBloc() : super(MyInitial()) {
    on<LoginEvent>(_onLogin);
    on<PlayAudioEvent>(_onPlayAudio);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<MyState> emit) async {
    try {
      final user = UserModel(
        userKey: 'user123',
        firstName: 'John',
        isLoggedIn: true,
      );
      await _userRepo.saveUser(user);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  Future<void> _onPlayAudio(PlayAudioEvent event, Emitter<MyState> emit) async {
    final play = RecentPlayModel(
      id: '1',
      audioName: 'Chapter 1',
      audioPath: '/path',
      chapterSlug: 'ch-1',
      ebookSlug: 'book-1',
      audioSlug: 'audio-1',
      playDate: DateTime.now(),
    );
    await _recentPlayRepo.addOrUpdateRecentPlay(play);
  }
}
```

### 3. Use in Widget
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _userRepo = GetIt.I<UserRepository>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userRepo.getLoggedInUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Text('Hello ${user?.firstName ?? "Guest"}');
      },
    );
  }
}
```

---

## API Summary

### 📦 All Repositories

| Repository | Key Methods |
|------------|------------|
| **UserRepository** | `getLoggedInUser()`, `saveUser()`, `deleteUser()`, `isUserLoggedIn()`, `logoutUser()` |
| **RecentPlayRepository** | `getAllRecentPlays()`, `addOrUpdateRecentPlay()`, `deleteRecentPlayByAudioSlug()`, `watchRecentPlays()` |
| **BookmarkRepository** | `getAllBookmarks()`, `addBookmark()`, `deleteBookmarkByEbookSlug()`, `isBookmarked()`, `watchBookmarks()` |
| **DownloadRepository** | `getAllDownloads()`, `saveDownload()`, `updateDownloadProgress()`, `deleteDownloadById()`, `getTotalDownloadSize()`, `watchDownloads()` |
| **SupportTicketRepository** | `getAllTickets()`, `createTicket()`, `getTicketsByUserKey()`, `updateTicket()`, `deleteTicket()`, `watchTickets()` |
| **NotificationRepository** | `getAllNotifications()`, `addNotification()`, `markAsRead()`, `markAllAsRead()`, `getUnreadCount()`, `watchNotifications()` |
| **AppSettingsRepository** | `getSettingValue()`, `saveSetting()`, `getSettingByKey()`, `deleteSetting()` |

---

## Key Features

✨ **Advantages of New System:**

1. **Single Database** - No mixing of technologies (Hive only)
2. **Type-Safe** - Models with compile-time type checking
3. **Fast** - Hive is optimized for mobile
4. **Reactive** - Stream-based updates with `watch*()`
5. **Easy Testing** - Mock repositories easily
6. **Clean Architecture** - Repository pattern with DI
7. **No SQL** - No SQL syntax errors, migrations, etc.
8. **Automatic Adapters** - Build runner generates serialization code

---

## Next Steps

### 🔄 Immediate Actions:

1. **Generate Hive Adapters** (Required!)
   ```bash
   flutter pub run build_runner build
   ```

2. **Remove Old Database Code**
   - Delete `app_database.dart` and `app_database.g.dart`
   - Delete `shared_prefs_config.dart`
   - Remove these imports from files

3. **Update All BLoCs**
   - Replace `StorageConfig` → `UserRepository`
   - Replace `AppDatabase` → `RecentPlayRepository`
   - Replace old `DownloadsDatabase` → `DownloadRepository`

4. **Update Main.dart**
   - Ensure `setupDI()` is called first

5. **Test Migration**
   - Run `flutter pub get`
   - Run `flutter run`

### 📚 Reference Files:

- **HIVE_DATABASE_GUIDE.md** - Full API documentation
- **MIGRATION_GUIDE.md** - Step-by-step migration from old system
- **di.dart** - See how repositories are registered

---

## Common Patterns

### Save Data
```dart
final repo = GetIt.I<UserRepository>();
final user = UserModel(userKey: 'u1', firstName: 'John', isLoggedIn: true);
await repo.saveUser(user);
```

### Get Data
```dart
final repo = GetIt.I<UserRepository>();
final user = await repo.getLoggedInUser();
```

### Watch Data (Reactive)
```dart
final repo = GetIt.I<RecentPlayRepository>();
repo.watchRecentPlays().listen((plays) {
  print('Plays updated: ${plays.length}');
});
```

### Delete Data
```dart
final repo = GetIt.I<BookmarkRepository>();
await repo.deleteBookmarkByEbookSlug('book-1');
```

### Filter Data
```dart
final repo = GetIt.I<RecentPlayRepository>();
final plays = await repo.getRecentPlaysByEbook('book-1');
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Adapter not registered" | Run `flutter pub run build_runner build` |
| Data not persisting | Ensure `setupDI()` called in main() |
| "GetIt is not registered" | Make sure `GetIt.I<RepositoryType>()` matches DI setup |
| Imports not found | Run `flutter pub get` |
| Build errors | Run `flutter clean && flutter pub get` |

---

## Architecture Diagram

```
┌─────────────────────────────────────┐
│   UI Layer (Widgets/BLoCs)          │
└──────────────┬──────────────────────┘
               │ 
┌──────────────▼──────────────────────┐
│   Repository Layer (Abstraction)    │
│ ┌────────────────────────────────┐  │
│ │ UserRepository                 │  │
│ │ RecentPlayRepository           │  │
│ │ BookmarkRepository             │  │
│ │ DownloadRepository             │  │
│ │ SupportTicketRepository        │  │
│ │ NotificationRepository         │  │
│ │ AppSettingsRepository          │  │
│ └────────────────────────────────┘  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   HiveDatabase (Manager)            │
│ ┌────────────────────────────────┐  │
│ │ Manages all boxes              │  │
│ │ Handles initialization         │  │
│ └────────────────────────────────┘  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Hive Boxes (Local Storage)        │
│ ┌────────────────────────────────┐  │
│ │ users | recent_plays | ...     │  │
│ │ downloads | bookmarks | ...    │  │
│ │ notifications | settings       │  │
│ └────────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## Support

For detailed information:
- **Full Guide**: See `HIVE_DATABASE_GUIDE.md`
- **Migration Help**: See `MIGRATION_GUIDE.md`
- **Code Examples**: See BLoC and repository implementations
