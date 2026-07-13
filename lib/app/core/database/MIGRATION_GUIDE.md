# Migration Guide: SharedPreferences & Drift → Hive Only

## Overview
This guide helps you migrate from the old database system (SharedPreferences + Drift + SQLite) to the new unified Hive-based system.

## Step 1: Update Imports

### Old System
```dart
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/shared_prefs_config.dart';
import 'package:haqvox/app/core/database/app_database.dart';
```

### New System
```dart
import 'package:get_it/get_it.dart';
import 'package:haqvox/app/core/database/repositories/index.dart';

final di = GetIt.instance;
```

---

## Step 2: User Data Migration

### Old: SharedPreferences Usage
```dart
StorageConfig config = StorageConfig();

// Save user data
await config.saveUserData(key: DBKeys.uFirstName, value: 'John');
await config.saveUserData(key: DBKeys.uLastName, value: 'Doe');
await config.saveUserData(key: DBKeys.uEmail, value: 'john@example.com');
await config.saveUserData(key: DBKeys.userKey, value: 'user123');

// Get user data
String? firstName = await config.getUserData(key: DBKeys.uFirstName);
String? userKey = await config.getUserData(key: DBKeys.userKey);

// Clear data
await config.clearAllData();
```

### New: Hive UserRepository
```dart
final userRepo = di<UserRepository>();

// Save user data
final user = UserModel(
  userKey: 'user123',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  isLoggedIn: true,
);
await userRepo.saveUser(user);

// Get user data
final loggedInUser = await userRepo.getLoggedInUser();
final firstName = loggedInUser?.firstName;

// Clear data
await userRepo.clearAllUsers();
```

---

## Step 3: Recent Plays Migration

### Old: Drift Usage
```dart
AppDatabase db = AppDatabase();

// Add or update recent play
await db.addOrUpdateRecentPlay(RecentPlaysCompanion(
  audioName: Value('Chapter 1'),
  audioPath: Value('/path/to/audio'),
  chapterSlug: Value('chapter-1'),
  ebookSlug: Value('book-1'),
  audioSlug: Value('audio-1'),
  playDate: Value(DateTime.now().toString()),
));

// Get all recent plays
final plays = await db.getAllRecentPlays();

// Get limited plays
final limitedPlays = await db.getLimitedRecentPlays(10);

// Delete recent play
await db.deleteRecentPlay('audio-slug');

// Clear all
await db.clearRecentPlays();
```

### New: Hive RecentPlayRepository
```dart
final recentPlayRepo = di<RecentPlayRepository>();

// Add or update recent play
final play = RecentPlayModel(
  id: 'play1',
  audioName: 'Chapter 1',
  audioPath: '/path/to/audio',
  chapterSlug: 'chapter-1',
  ebookSlug: 'book-1',
  audioSlug: 'audio-1',
  playDate: DateTime.now(),
);
await recentPlayRepo.addOrUpdateRecentPlay(play);

// Get all recent plays
final plays = await recentPlayRepo.getAllRecentPlays();

// Get limited plays
final limitedPlays = await recentPlayRepo.getLimitedRecentPlays(10);

// Delete recent play
await recentPlayRepo.deleteRecentPlayByAudioSlug('audio-slug');

// Clear all
await recentPlayRepo.clearAllRecentPlays();

// Watch for changes (reactive)
recentPlayRepo.watchRecentPlays().listen((plays) {
  print('Plays updated: ${plays.length}');
});
```

---

## Step 4: Downloads Migration

### Old: Hive DownloadsDatabase
```dart
DownloadsDatabase downloadsDb = DownloadsDatabase();

// Insert download
await downloadsDb.insertDownload(DownloadedAudioModel(
  id: 'audio1',
  title: 'Audio Title',
  url: 'https://...',
  localPath: '/path/to/file',
  artist: 'Artist Name',
  fileSize: 5000000,
  downloadDate: DateTime.now(),
  chapterTitle: 'Chapter 1',
  chapterSlug: 'chapter-1',
  ebookSlug: 'book-1',
));

// Get all downloads
final downloads = await downloadsDb.getAllDownloads();

// Get by URL
final download = await downloadsDb.getDownloadByUrl('https://...');

// Delete download
await downloadsDb.deleteDownload('audio1');

// Delete all
await downloadsDb.deleteAllDownloads();
```

### New: Hive DownloadRepository
```dart
final downloadRepo = di<DownloadRepository>();

// Save download (new or updated)
final download = DownloadedAudioModel(
  id: 'audio1',
  title: 'Audio Title',
  url: 'https://...',
  localPath: '/path/to/file',
  artist: 'Artist Name',
  coverUrl: 'https://...',
  fileSize: 5000000,
  downloadDate: DateTime.now(),
  chapterTitle: 'Chapter 1',
  chapterSlug: 'chapter-1',
  ebookSlug: 'book-1',
  ebookTitle: 'Book Title',
  status: 'completed', // NEW: download status
);
await downloadRepo.saveDownload(download);

// Get all downloads
final downloads = await downloadRepo.getAllDownloads();

// Get by URL
final download = await downloadRepo.getDownloadByUrl('https://...');

// NEW: Update progress during download
await downloadRepo.updateDownloadProgress('audio1', 50); // 50%

// NEW: Update status
await downloadRepo.updateDownloadStatus('audio1', 'downloading');

// Delete download
await downloadRepo.deleteDownloadById('audio1');

// Delete all
await downloadRepo.deleteAllDownloads();

// NEW: Get total download size
final totalSize = await downloadRepo.getTotalDownloadSize();

// NEW: Check if downloaded
final isDownloaded = await downloadRepo.isDownloaded('https://...');

// NEW: Watch for changes
downloadRepo.watchDownloads().listen((downloads) {
  print('Downloads updated: ${downloads.length}');
});
```

---

## Step 5: BLoC Migration Example

### Old: BLoC with SharedPreferences
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final StorageConfig _storageConfig = StorageConfig();

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<GetUserEvent>(_onGetUser);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      // ... API call ...
      
      // Save user data
      await _storageConfig.saveUserData(key: DBKeys.userKey, value: user.userKey);
      await _storageConfig.saveUserData(key: DBKeys.uFirstName, value: user.firstName);
      
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onGetUser(GetUserEvent event, Emitter<AuthState> emit) async {
    try {
      final userKey = await _storageConfig.getUserData(key: DBKeys.userKey);
      emit(UserLoaded(userKey: userKey));
    } catch (e) {
      emit(UserLoadFailure(e.toString()));
    }
  }
}
```

### New: BLoC with Hive Repository
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository _userRepository = GetIt.I<UserRepository>();

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<GetUserEvent>(_onGetUser);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      // ... API call ...
      
      // Save user data as a complete model
      final user = UserModel(
        userKey: apiUser.userKey,
        firstName: apiUser.firstName,
        lastName: apiUser.lastName,
        email: apiUser.email,
        isLoggedIn: true,
      );
      await _userRepository.saveUser(user);
      
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onGetUser(GetUserEvent event, Emitter<AuthState> emit) async {
    try {
      final user = await _userRepository.getLoggedInUser();
      emit(UserLoaded(user: user));
    } catch (e) {
      emit(UserLoadFailure(e.toString()));
    }
  }
}
```

---

## Step 6: Widget Migration Example

### Old: Widget with SharedPreferences
```dart
class HomeWidget extends StatefulWidget {
  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final _storageConfig = StorageConfig();
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final firstName = await _storageConfig.getUserData(key: DBKeys.uFirstName);
    setState(() => userName = firstName);
  }

  @override
  Widget build(BuildContext context) {
    return Text('Welcome, $userName');
  }
}
```

### New: Widget with Hive Repository (Modern)
```dart
class HomeWidget extends StatefulWidget {
  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final _userRepository = GetIt.I<UserRepository>();
  late StreamSubscription _userSubscription;

  @override
  void initState() {
    super.initState();
    // Optional: Watch user changes in real-time
    _userSubscription = _watchUserChanges();
  }

  StreamSubscription _watchUserChanges() {
    return _userRepository.watchUserData().listen((_) {
      setState(() {}); // Rebuild on changes
    });
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userRepository.getLoggedInUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Text('Welcome, ${user?.firstName ?? 'Guest'}');
      },
    );
  }
}
```

---

## Step 7: File-by-File Migration Checklist

### Files to Update

- [ ] **lib/app/src/home/view/home.dart**
  - Replace `StorageConfig` with `UserRepository`
  - Replace `DBKeys` access with user object

- [ ] **lib/app/src/auth/bloc/auth_bloc.dart**
  - Replace `StorageConfig` with `UserRepository`
  - Update save/get user logic

- [ ] **lib/app/src/Player/services/music_player_service.dart**
  - Replace Drift database with `RecentPlayRepository`
  - Update play history tracking

- [ ] **lib/app/src/myspace/view/myspace.dart**
  - Replace `StorageConfig` with `UserRepository`
  - Use `BookmarkRepository` for bookmarks

- [ ] **lib/app/src/support/repositories/ticket_repo.dart**
  - Replace `StorageConfig` with `SupportTicketRepository`

- [ ] All other BLoCs and Services
  - Update database access patterns

### Database Files to Remove

- [ ] `lib/app/core/database/app_database.dart` (Drift)
- [ ] `lib/app/core/database/app_database.g.dart` (Generated)
- [ ] `lib/app/core/database/shared_prefs_config.dart`
- [ ] Old database initialization code

---

## Step 8: Testing the Migration

### Unit Test Example
```dart
void main() {
  group('UserRepository Migration Tests', () {
    late UserRepository userRepository;

    setUp(() {
      userRepository = UserRepository();
    });

    test('save and retrieve user', () async {
      final user = UserModel(
        userKey: 'test123',
        firstName: 'Test',
        isLoggedIn: true,
      );

      await userRepository.saveUser(user);
      final retrieved = await userRepository.getUserByKey('test123');

      expect(retrieved?.firstName, 'Test');
      expect(retrieved?.isLoggedIn, true);
    });

    test('check login status', () async {
      final isLoggedIn = await userRepository.isUserLoggedIn();
      expect(isLoggedIn, true); // After setup
    });
  });
}
```

---

## Step 9: Build and Generate Adapters

After updating all files:

```bash
# Generate Hive adapters
flutter pub run build_runner build

# Run the app
flutter run
```

---

## Common Migration Issues

### Issue 1: "Adapter not registered"
**Solution:** Run `flutter pub run build_runner build`

### Issue 2: Type mismatch errors
**Solution:** Ensure model fields match the HiveType fields and typeIds

### Issue 3: Data not found after migration
**Solution:** Old data in SharedPreferences is separate; you may need to:
1. Export old data
2. Convert to new models
3. Save with new repositories

### Issue 4: Performance issues
**Solution:** 
- Use pagination for large lists
- Use stream watchers for reactive updates
- Avoid frequent box opens/closes

---

## Verification Checklist

- [ ] All imports updated to use repositories
- [ ] DI setup includes all repositories
- [ ] Hive adapters generated (`flutter pub run build_runner build`)
- [ ] App initializes HiveDatabase in main()
- [ ] All BLoCs updated to use repositories
- [ ] All widgets updated to access data via repositories
- [ ] Tests pass with new system
- [ ] No SharedPreferences or Drift imports remain
- [ ] pubspec.yaml updated (removed drift, sqlite3)
- [ ] App builds and runs successfully

---

## Need Help?

Refer to **HIVE_DATABASE_GUIDE.md** for detailed API documentation and usage examples.
