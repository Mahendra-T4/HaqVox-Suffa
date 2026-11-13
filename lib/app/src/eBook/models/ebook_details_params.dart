class EBooksDetailsParams {
  final String eBookName;
  final String eBookImage;
  final String eBookDescription;
  final String ebookTagline;
  final String ebookSlug;
  final int? bookmarkStatus;

  EBooksDetailsParams(
      {required this.eBookName,
      required this.eBookImage,
      required this.eBookDescription,
      required this.ebookTagline,
      required this.ebookSlug,
      this.bookmarkStatus,
      });
}
