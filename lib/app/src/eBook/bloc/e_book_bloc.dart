import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:haqvox/app/src/eBook/models/chapter_audio_entity.dart';
import 'package:haqvox/app/src/eBook/models/ebook_chepter_entity.dart';
import 'package:haqvox/app/src/eBook/models/ebook_entity.dart';
import 'package:haqvox/app/src/eBook/repositories/ebook_repo.dart';


part 'e_book_event.dart';
part 'e_book_state.dart';

class EBookBloc extends Bloc<EBookEvent, EBookState> {
  EBookBloc() : super(EBookInitial()) {
    on<EBookListFetchFromServerEvent>(_eBookListFetchFromServerEvent);
    on<EBookGeneraFromServerEvent>(_eBookGeneraFromServerEvent);
    on<EBookChapterFetchingEvent>(_eBookChapterFetchingEvent);
    on<EBookChapterAudioFetchingEvent>(_eBookChapterAudioFetchingEvent);
  }

  FutureOr<void> _eBookListFetchFromServerEvent(
      EBookListFetchFromServerEvent event, Emitter<EBookState> emit) async {
    emit(EBookLoadingState());
    try {
      final eBooks =
          await EBookRepository.eBooks(filterBy: event.filter.toString());
      if (eBooks.status == 1) {
        emit(EBookLoadFromServerSuccessState(eBookEntity: eBooks));
      }
    } catch (e) {
      log('eBook List Load Error From Bloc $e');
      emit(EBookLoadFromServerFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _eBookChapterFetchingEvent(
      EBookChapterFetchingEvent event, Emitter<EBookState> emit) async {
    emit(EBookLoadingState());
    try {
      final eBookChapters =
          await EBookRepository.eBooksChapters(ebookSlug: event.ebookSlug);
      emit(EBookChapterLoadedSuccessState(eBookChapterEntity: eBookChapters));
    } catch (e) {
      log('eBook Chapters Load Error From Bloc $e');
      emit(EBookChapterFailedToLoadErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _eBookChapterAudioFetchingEvent(
      EBookChapterAudioFetchingEvent event, Emitter<EBookState> emit) async {
    emit(EBookLoadingState());
    try {
      final eBookChaptersAudio = await EBookRepository.eBookChaptersAudio(
          chapterSlug: event.chapterSlug, ebookSlug: event.ebookSlug);

      emit(EBookChapterAudioLoadedSuccessState(
          chapterAudioEntity: eBookChaptersAudio));
    } catch (e) {
      log('eBook Chapter Audio Load Error From Bloc $e');
      emit(EBookChapterAudioFailedToLoadErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _eBookGeneraFromServerEvent(
      EBookGeneraFromServerEvent event, Emitter<EBookState> emit) async {
    emit(EBookLoadingState());
    try {
      final eBooks = await EBookRepository.genres(
          categorySlug: event.categorySlug.toString());
      if (eBooks.status == 1) {
        emit(EBookLoadFromServerSuccessState(eBookEntity: eBooks));
      }
    } catch (e) {
      log('eBook List Load Error From Bloc $e');
      emit(EBookLoadFromServerFailedErrorState(error: e.toString()));
    }
  }
}
