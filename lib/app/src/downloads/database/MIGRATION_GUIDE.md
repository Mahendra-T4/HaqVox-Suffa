## Hive Database Migration Guide

### Changes Made:
The Drift database has been converted to Hive for better lightweight performance.

### New Files:
1. `lib/app/src/downloads/database/models/downloaded_audio_model.dart` - Hive model class
2. `lib/app/src/downloads/database/downloads_hive_db.dart` - Hive database service

### Setup Instructions:

#### 1. Update your main.dart or app initialization:
```dart
import 'package:haqvox/app/src/downloads/database/downloads_hive_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await DownloadsDatabase.init();
  
  runApp(const MyApp());
}
```

#### 2. Code Migration Examples:

**Old (Drift):**
```dart
final db = DownloadsDatabase();
final downloads = await db.getAllDownloads();
await db.deleteDownload(id);
```

**New (Hive):**
```dart
final db = DownloadsDatabase();
final downloads = await db.getAllDownloads();
await db.deleteDownload(id);
```

#### 3. Creating a Download:

**Old:**
```dart
await db.insertDownload(DownloadedAudiosCompanion(
  id: Value('123'),
  title: Value('title'),
  url: Value('url'),
  // ... other fields
));
```

**New:**
```dart
await db.insertDownload(DownloadedAudioModel(
  id: '123',
  title: 'title',
  url: 'url',
  localPath: '/path/to/file',
  artist: 'artist',
  chapterTitle: 'chapter',
  chapterSlug: 'slug',
  ebookSlug: 'ebook-slug',
  fileSize: 1024,
  downloadDate: DateTime.now(),
));
```

### Method Reference:

| Method | Description |
|--------|-------------|
| `init()` | Initialize Hive (call once in main) |
| `getAllDownloads()` | Get all downloads |
| `getDownloadsByChapter(slug)` | Get downloads for a chapter |
| `getDownloadByUrl(url)` | Get single download by URL |
| `insertDownload(model)` | Insert new download |
| `updateDownload(id, model)` | Update existing download |
| `deleteDownload(id)` | Delete download and its file |
| `deleteAllDownloads()` | Delete all downloads and files |
| `getDownloadCount()` | Get total number of downloads |
| `getTotalDownloadSize()` | Get total size of all downloads |
| `searchByTitle(query)` | Search downloads by title |
| `searchByArtist(query)` | Search downloads by artist |
| `downloadExists(url)` | Check if URL already downloaded |

### Benefits:
- ✅ Lightweight and faster performance
- ✅ No code generation needed (no .g.dart files)
- ✅ Simpler setup and configuration
- ✅ Native Dart async/await support
- ✅ Built-in search and filter capabilities
- ✅ Reduced app size

### Next Steps:
1. Run `flutter pub get` to ensure dependencies are installed
2. Find all imports of the old `downloads_database.dart`
3. Replace with imports of `downloads_hive_db.dart`
4. Update initialization in your main.dart
5. Update all database calls using the method reference above
6. Run `flutter clean && flutter pub get && flutter run`

### Generate Hive Adapter (if needed):
If you modify the DownloadedAudioModel, regenerate the adapter:
```bash
flutter pub run build_runner build
```

### Troubleshooting:
- If you see adapter registration errors, make sure `downloaded_audio_model.g.dart` is generated
- Clear Hive cache if you have data migration issues: `await DownloadsDatabase.deleteBox()`
