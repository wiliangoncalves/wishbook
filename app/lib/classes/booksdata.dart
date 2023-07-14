class BookClass {
  String _title = '';
  final int _booksId = -1;
  List _authors = [];
  final List _authorsId = [];

  String get getTitle {
    return _title;
  }

  set setTitle(String title) {
    _title = title;
  }

  int get getBooksId {
    return _booksId;
  }

  List get getAuthors {
    return _authors;
  }

  set setAuthors(List authors) {
    _authors = authors;
  }

  List get getAuthorsId {
    return _authorsId;
  }
}