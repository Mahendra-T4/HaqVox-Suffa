# Haqvox Database Architecture - Hive Only

## Overview

This project has been refactored to use **Hive** as the single source of truth for all local database operations. All data is now managed through Hive boxes with a proper repository pattern for clean architecture.

## Architecture Layers

```
┌─────────────────────────────────────────────┐
│          UI Layer (BLoCs, Widgets)          │
├─────────────────────────────────────────────┤
│       Repository Layer (Abstraction)        │
├─────────────────────────────────────────────┤
│     HiveDatabase (Box Management)           │
├─────────────────────────────────────────────┤
│    Hive Models (Data Entities)              │
├─────────────────────────────────────────────┤
│     Local Storage (Hive Boxes)              │
└─────────────────────────────────────────────┘
```

## Data Models

### 1. **UserModel** (typeId: 1)
Stores user authentication and profile information.
```dart
UserModel(
  userKey, firstName, lastName, email, mobile,
  alternateNumber, dateOfBirth, gender,
  userCode, profileImage, localProfileImagePath,
  subscriptionStatus, isLoggedIn, createdAt, updatedAt
)
```
**Box Name:** `users`

### 2. **RecentPlayModel** (typeId: 2)
Stores play history and recent listening records.
```dart
RecentPlayModel(
  id, audioName, audioPath, chapterSlug,
  ebookSlug, audioSlug, playDate,
  thumbnailUrl, duration, position,
  chapterTitle, ebookName
)
```
**Box Name:** `recent_plays`

### 3. **BookmarkModel** (typeId: 3)
Stores bookmarked books.
```dart
BookmarkModel(
  id, ebookSlug, ebookName,
  ebookImage, ebookIcon, description,
  bookmarkedAt, authorName
)
```
**Box Name:** `bookmarks`

### 4. **DownloadedAudioModel** (typeId: 0)
Stores downloaded audio files metadata and status.
```dart
DownloadedAudioModel(
  id, title, url, localPath, artist,
  coverUrl, fileSize, downloadDate,
  chapterTitle, chapterSlug, ebookSlug,
  ebookTitle, downloadProgress, status
)
```
**Box Name:** `downloads`

### 5. **SupportTicketModel** (typeId: 4)
Stores user support tickets.
```dart
SupportTicketModel(
  ticketId, subject, description, supportType,
  status, createdAt, updatedAt,
  priority, assignedTo, attachmentUrls, userKey
)
```
**Box Name:** `support_tickets`

### 6. **NotificationModel** (typeId: 5)
Stores notifications.
```dart
NotificationModel(
  id, title, message, type,
  createdAt, isRead, actionUrl, imageUrl
)
```
**Box Name:** `notifications`

### 7. **AppSettingsModel** (typeId: 6)
Stores app settings and preferences.
```dart
AppSettingsModel(
  key, value, createdAt, updatedAt
)
```
**Box Name:** `app_settings`

## Repositories

Each model has a corresponding repository that provides CRUD operations and specialized queries:

### UserRepository
- `getLoggedInUser()` - Get current user
- `saveUser(user)` - Save or update user
- `getUserByKey(userKey)` - Get user by ID
- `deleteUser(userKey)` - Delete user
- `isUserLoggedIn()` - Check login status
- `logoutUser()` - Logout user
- `getAllUsers()` - Get all users

### RecentPlayRepository
- `getAllRecentPlays()` - Get all plays (newest first)
- `getLimitedRecentPlays(limit)` - Get limited plays
- `getRecentPlaysByEbook(ebookSlug)` - Filter by ebook
- `getRecentPlaysByChapter(chapterSlug)` - Filter by chapter
- `addOrUpdateRecentPlay(play)` - Add or update play
- `deleteRecentPlayByAudioSlug(audioSlug)` - Delete play
- `clearAllRecentPlays()` - Clear all
- `watchRecentPlays()` - Stream recent plays

### BookmarkRepository
- `getAllBookmarks()` - Get all bookmarks
- `getBookmarkById(id)` - Get by ID
- `getBookmarkByEbookSlug(ebookSlug)` - Get by ebook
- `isBookmarked(ebookSlug)` - Check if bookmarked
- `addBookmark(bookmark)` - Add bookmark
- `deleteBookmarkById(id)` - Delete bookmark
- `deleteBookmarkByEbookSlug(ebookSlug)` - Delete by ebook
- `watchBookmarks()` - Stream bookmarks

### DownloadRepository
- `getAllDownloads()` - Get all downloads
- `getDownloadsByChapter(chapterSlug)` - Filter by chapter
- `getDownloadsByEbook(ebookSlug)` - Filter by ebook
- `getDownloadByUrl(url)` - Get by URL
- `getDownloadById(id)` - Get by ID
- `saveDownload(download)` - Save or update
- `updateDownloadProgress(id, progress)` - Update progress
- `updateDownloadStatus(id, status)` - Update status
- `deleteDownloadById(id)` - Delete by ID
- `deleteAllDownloads()` - Delete all (with file cleanup)
- `isDownloaded(url)` - Check if downloaded
- `getTotalDownloadSize()` - Get total size
- `watchDownloads()` - Stream downloads

### SupportTicketRepository
- `getAllTickets()` - Get all tickets
- `getTicketsByUserKey(userKey)` - Get user's tickets
- `getTicketsByStatus(status)` - Filter by status
- `getTicketById(ticketId)` - Get by ID
- `createTicket(ticket)` - Create new ticket
- `updateTicket(ticket)` - Update ticket
- `deleteTicket(ticketId)` - Delete ticket
- `watchTickets()` - Stream tickets

### NotificationRepository
- `getAllNotifications()` - Get all notifications
- `getUnreadNotifications()` - Get unread only
- `getNotificationsByType(type)` - Filter by type
- `getNotificationById(id)` - Get by ID
- `addNotification(notification)` - Add notification
- `markAsRead(id)` - Mark single as read
- `markAllAsRead()` - Mark all as read
- `deleteNotification(id)` - Delete notification
- `getUnreadCount()` - Get unread count
- `watchNotifications()` - Stream notifications

### AppSettingsRepository
- `getAllSettings()` - Get all settings
- `getSettingByKey(key)` - Get by key
- `saveSetting(setting)` - Save setting
- `saveSettingByKeyValue(key, value)` - Save by key-value
- `getSettingValue(key, defaultValue)` - Get value with default
- `deleteSetting(key)` - Delete setting
- `watchSettings()` - Stream settings

## Setup & Initialization

### 1. Dependency Injection (DI)
All repositories are registered as singletons in `di.dart`:

```dart
Future<void> setupDI() async {
  // Initialize Hive Database first
  final hiveDb = HiveDatabase();
  await hiveDb.init();
  di.registerSingleton<HiveDatabase>(hiveDb);

  // Register all repositories
  di.registerSingleton<UserRepository>(UserRepository());
  di.registerSingleton<RecentPlayRepository>(RecentPlayRepository());
  // ... other repositories
}
```

### 2. Generate Hive Adapters
Before running the app, generate Hive adapters:

```bash
flutter pub run build_runner build
```

Or watch for changes:
```bash
flutter pub run build_runner watch
```

### 3. Main Initialization
In `main.dart`, HiveDatabase is initialized first:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDI(); // Sets up Hive + all repositories
  // ... rest of initialization
}
```

## Usage Examples

### Save User Data
```dart
final userRepo = di<UserRepository>();
final user = UserModel(
  userKey: 'user123',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  isLoggedIn: true,
);
await userRepo.saveUser(user);
```

### Track Recent Play
```dart
final recentPlayRepo = di<RecentPlayRepository>();
final play = RecentPlayModel(
  id: '1',
  audioName: 'Chapter 1',
  audioPath: '/path/to/audio',
  chapterSlug: 'chapter-1',
  ebookSlug: 'book-1',
  audioSlug: 'audio-1',
  playDate: DateTime.now(),
);
await recentPlayRepo.addOrUpdateRecentPlay(play);
```

### Add Bookmark
```dart
final bookmarkRepo = di<BookmarkRepository>();
final bookmark = BookmarkModel(
  id: 'bookmark1',
  ebookSlug: 'book-1',
  ebookName: 'Book Title',
  bookmarkedAt: DateTime.now(),
);
await bookmarkRepo.addBookmark(bookmark);
```

### Download Management
```dart
final downloadRepo = di<DownloadRepository>();

// Save download
final download = DownloadedAudioModel(...);
await downloadRepo.saveDownload(download);

// Update progress
await downloadRepo.updateDownloadProgress(downloadId, 50);

// Get all downloads
final downloads = await downloadRepo.getAllDownloads();
```

### Stream Data (Reactive)
```dart
final recentPlayRepo = di<RecentPlayRepository>();

recentPlayRepo.watchRecentPlays().listen((plays) {
  print('Recent plays updated: ${plays.length}');
  setState(() => recentPlays = plays);
});
```

## Migrating from Old System

### From SharedPreferences (User Data)
**Old:**
```dart
StorageConfig config = StorageConfig();
await config.saveUserData(key: DBKeys.uFirstName, value: 'John');
```

**New:**
```dart
UserRepository userRepo = di<UserRepository>();
UserModel user = UserModel(firstName: 'John', ...);
await userRepo.saveUser(user);
```

### From Drift (Recent Plays)
**Old:**
```dart
AppDatabase db = AppDatabase();
await db.addOrUpdateRecentPlay(entry);
```

**New:**
```dart
RecentPlayRepository repo = di<RecentPlayRepository>();
RecentPlayModel play = RecentPlayModel(...);
await repo.addOrUpdateRecentPlay(play);
```

### From Old Hive (Downloads)
**Old:**
```dart
DownloadsDatabase downloadsDb = DownloadsDatabase();
await downloadsDb.insertDownload(model);
```

**New:**
```dart
DownloadRepository downloadRepo = di<DownloadRepository>();
await downloadRepo.saveDownload(model);
```

## Best Practices

1. **Always use repositories** - Never access HiveDatabase directly from BLoCs or UI
2. **Use GetIt for injection** - Access via `di<RepositoryType>()`
3. **Handle errors gracefully** - Repositories return empty lists/null on error
4. **Use streams for real-time** - Use `watch*()` methods for reactive updates
5. **Initialize DI first** - Call `setupDI()` in main() before creating widgets
6. **Generate adapters** - Run `build_runner` after adding/modifying models
7. **Close database** - Call `HiveDatabase().close()` on app shutdown (optional)

## File Structure
```
lib/app/core/database/
├── hive_database.dart              # Main Hive manager
├── hive_models/
│   ├── index.dart                  # Model exports
│   ├── user_model.dart
│   ├── recent_play_model.dart
│   ├── bookmark_model.dart
│   ├── downloaded_audio_model.dart
│   ├── support_ticket_model.dart
│   ├── notification_model.dart
│   └── app_settings_model.dart
├── repositories/
│   ├── index.dart                  # Repository exports
│   ├── user_repository.dart
│   ├── recent_play_repository.dart
│   ├── bookmark_repository.dart
│   ├── download_repository.dart
│   ├── support_ticket_repository.dart
│   ├── notification_repository.dart
│   └── app_settings_repository.dart
├── dependency_injection/
│   └── di.dart                     # DI setup
└── HIVE_DATABASE_GUIDE.md          # This file
```

## Troubleshooting

### "Adapter not registered" Error
Solution: Run `flutter pub run build_runner build`

### Data not persisting
Solution: Check that `HiveDatabase().init()` is called before accessing data

### Performance issues with large datasets
Solution: Use `getLimited*()` methods and pagination for large lists

### Migration from SharedPreferences
Solution: See MIGRATION_GUIDE.md for detailed steps

## Testing

For unit tests, mock repositories:
```dart
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  test('user login', () async {
    final mockRepo = MockUserRepository();
    when(mockRepo.getLoggedInUser()).thenAnswer((_) async => testUser);
    
    final user = await mockRepo.getLoggedInUser();
    expect(user, testUser);
  });
}
```

## Performance Considerations

- **Hive** is optimized for mobile devices
- No network calls needed for local data
- Instant read/write operations
- Streaming enables reactive UI updates
- Memory efficient for large datasets

## Future Enhancements

- [ ] Encryption for sensitive data
- [ ] Database backup/restore
- [ ] Data sync with cloud backend
- [ ] Advanced querying with filters
- [ ] Database versioning/migration
