import 'package:haqvox/app/core/database/hive_database.dart';
import 'package:haqvox/app/core/database/hive_models/bookmark_model.dart';

/// Bookmark Repository - Handles all bookmark-related database operations
class BookmarkRepository {
  final HiveDatabase _hiveDatabase = HiveDatabase();

  /// Get all bookmarks
  Future<List<BookmarkModel>> getAllBookmarks() async {
    try {
      return _hiveDatabase.bookmarkBox.values.toList();
    } catch (e) {
      print('Error getting all bookmarks: $e');
      return [];
    }
  }

  /// Get bookmark by ID
  Future<BookmarkModel?> getBookmarkById(String id) async {
    try {
      return _hiveDatabase.bookmarkBox.get(id);
    } catch (e) {
      print('Error getting bookmark by ID: $e');
      return null;
    }
  }

  /// Get bookmark by ebook slug
  Future<BookmarkModel?> getBookmarkByEbookSlug(String ebookSlug) async {
    try {
      final bookmarks = _hiveDatabase.bookmarkBox.values
          .where((b) => b.ebookSlug == ebookSlug)
          .toList();
      return bookmarks.isNotEmpty ? bookmarks.first : null;
    } catch (e) {
      print('Error getting bookmark by ebook slug: $e');
      return null;
    }
  }

  /// Check if ebook is bookmarked
  Future<bool> isBookmarked(String ebookSlug) async {
    try {
      final bookmark = await getBookmarkByEbookSlug(ebookSlug);
      return bookmark != null;
    } catch (e) {
      return false;
    }
  }

  /// Add bookmark
  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      await _hiveDatabase.bookmarkBox.put(bookmark.id, bookmark);
    } catch (e) {
      print('Error adding bookmark: $e');
      rethrow;
    }
  }

  /// Delete bookmark by ID
  Future<void> deleteBookmarkById(String id) async {
    try {
      await _hiveDatabase.bookmarkBox.delete(id);
    } catch (e) {
      print('Error deleting bookmark by ID: $e');
      rethrow;
    }
  }

  /// Delete bookmark by ebook slug
  Future<void> deleteBookmarkByEbookSlug(String ebookSlug) async {
    try {
      final bookmark = await getBookmarkByEbookSlug(ebookSlug);
      if (bookmark != null) {
        await deleteBookmarkById(bookmark.id);
      }
    } catch (e) {
      print('Error deleting bookmark by ebook slug: $e');
      rethrow;
    }
  }

  /// Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    try {
      await _hiveDatabase.bookmarkBox.clear();
    } catch (e) {
      print('Error clearing all bookmarks: $e');
      rethrow;
    }
  }

  /// Get bookmarks count
  Future<int> getBookmarksCount() async {
    try {
      return _hiveDatabase.bookmarkBox.length;
    } catch (e) {
      return 0;
    }
  }

  /// Watch bookmarks (stream)
  Stream<List<BookmarkModel>> watchBookmarks() async* {
    try {
      yield await getAllBookmarks();
      await for (final _ in _hiveDatabase.bookmarkBox.watch()) {
        yield await getAllBookmarks();
      }
    } catch (e) {
      print('Error watching bookmarks: $e');
      yield [];
    }
  }
}
