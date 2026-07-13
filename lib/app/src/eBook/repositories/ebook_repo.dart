import 'dart:convert';
import 'dart:developer';
import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/src/eBook/models/chapter_audio_entity.dart';
import 'package:haqvox/app/src/eBook/models/ebook_chepter_entity.dart';
import 'package:haqvox/app/src/eBook/models/ebook_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

abstract class EBookRepository {
  static final client = http.Client();
  // static StorageConfig _config = StorageConfig();
  static final url = Uri.parse(Environment.baseUrl);

  static Future<EBookEntity> eBooks({required String filterBy}) async {
    final boxName = 'ebookBox';
    List<EBookRecord> ebooks = [];
    int? status;
    String? message;
    try {
      final response = await client.post(
        url,
        body: {'activity': 'ebook', 'filterBy': filterBy},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log(response.body);

        final ebookList =
            (jsonResponse['record'] as List)
                .map((ebooks) => EBookRecord.fromJson(ebooks))
                .toList();

        status = jsonResponse['status'];
        message = jsonResponse['message'];

        final box = await Hive.openBox<EBookRecord>(boxName);
        await box.clear();
        await box.addAll(ebookList);

        ebooks = ebookList;

        // return EBookEntity.fromJson(jsonResponse);
      } else {
        log('Failed to load eBooks');
        // return EBookEntity(
        //   status: response.statusCode,

        //   message: 'Failed to load eBooks',
        // );
      }
    } catch (SocketException) {
      final box = await Hive.openBox<EBookRecord>(boxName);
      ebooks = box.values.toList();
      log('eBook Error From Repo : $SocketException');
    }
    return EBookEntity(status: status, message: message, record: ebooks);
  }

  static Future<EBookEntity> genres({required String categorySlug}) async {
    try {
      final response = await client.post(
        url,
        body: {'activity': 'ebook', 'categorySlug': categorySlug},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log(response.body);
        return EBookEntity.fromJson(jsonResponse);
      } else {
        log('Failed to load eBooks');
        return EBookEntity(
          status: response.statusCode,
          message: 'Failed to load eBooks',
        );
      }
    } catch (e) {
      log('eBook Error From Repo : $e');
      return EBookEntity(status: 500, message: e.toString());
    }
  }

  static Future<EBookChapterEntity> eBooksChapters({
    required String ebookSlug,
  }) async {
    try {
      final response = await client.post(
        url,
        body: {'activity': 'chapter', 'ebookSlug': ebookSlug},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log(response.body);
        return EBookChapterEntity.fromJson(jsonResponse);
      } else {
        log('Failed to load eBook Chapters');
        return EBookChapterEntity(
          status: response.statusCode,
          message: 'Failed to load eBook Chapters',
        );
      }
    } catch (e) {
      log('eBook Chapter Error From Repo : $e');
      return EBookChapterEntity(status: 500, message: e.toString());
    }
  }

  static Future<ChapterAudioEntity> eBookChaptersAudio({
    required String chapterSlug,
    required String ebookSlug,
  }) async {
    try {
      final response = await client.post(
        url,
        body: {
          'activity': 'audio',
          'chapterSlug': chapterSlug,
          'ebookSlug': ebookSlug,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log(response.body);
        return ChapterAudioEntity.fromJson(jsonResponse);
      } else {
        log('Failed to load chapter audio');
        return ChapterAudioEntity(
          status: response.statusCode,
          message: 'Failed to load chapter audio',
        );
      }
    } catch (e) {
      log('Chapter Audio Error From Repo : $e');
      return ChapterAudioEntity(status: 500, message: e.toString());
    }
  }
}
