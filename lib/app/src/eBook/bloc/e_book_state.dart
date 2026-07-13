part of 'e_book_bloc.dart';

sealed class EBookState {}

final class EBookInitial extends EBookState {}

final class EBookLoadingState extends EBookState {}

//! eBook States

final class EBookLoadFromServerSuccessState extends EBookState {
  final EBookEntity eBookEntity;

  EBookLoadFromServerSuccessState({required this.eBookEntity});
}

final class EBookLoadFromServerFailedErrorState extends EBookState {
  final String error;

  EBookLoadFromServerFailedErrorState({required this.error});
}

//! eBook Chapter States

final class EBookChapterLoadedSuccessState extends EBookState {
  final EBookChapterEntity eBookChapterEntity;

  EBookChapterLoadedSuccessState({required this.eBookChapterEntity});
}

final class EBookChapterFailedToLoadErrorState extends EBookState {
  final String error;

  EBookChapterFailedToLoadErrorState({required this.error});
}

//! eBook Chapters Audio States

final class EBookChapterAudioLoadedSuccessState extends EBookState {
  final ChapterAudioEntity chapterAudioEntity;

  EBookChapterAudioLoadedSuccessState({required this.chapterAudioEntity});
}

final class EBookChapterAudioFailedToLoadErrorState extends EBookState {
  final String error;

  EBookChapterAudioFailedToLoadErrorState({required this.error});

}
