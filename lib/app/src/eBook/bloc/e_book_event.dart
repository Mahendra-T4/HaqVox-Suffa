part of 'e_book_bloc.dart';

sealed class EBookEvent {}

final class EBookListFetchFromServerEvent extends EBookEvent {

    final String? filter;

  EBookListFetchFromServerEvent({this.filter});
}

final class EBookGeneraFromServerEvent extends EBookEvent {
   final String? categorySlug;
   

  EBookGeneraFromServerEvent({this.categorySlug,});
}


final class EBookChapterFetchingEvent extends EBookEvent {
  final String ebookSlug;

  EBookChapterFetchingEvent({required this.ebookSlug});
}

final class EBookChapterAudioFetchingEvent extends EBookEvent {
  final String chapterSlug;
  final String ebookSlug;

  EBookChapterAudioFetchingEvent(
      {required this.chapterSlug, required this.ebookSlug});
}
