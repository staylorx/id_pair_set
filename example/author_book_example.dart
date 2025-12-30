// ignore_for_file: avoid_print

import 'package:id_pair_set/id_pair_set.dart';

/// Example demonstrating how to use IdPairSet for managing Authors and Books with multiple identifiers.
/// This is a simple example showing the basic usage of IdPairSet.
///
/// This example shows:
/// - Using IdPairSet to manage multiple identifiers for Authors and Books
/// - Filtering identifiers by type
/// - Handling duplicate identifier types (IdPairSet keeps the last one)
///
/// Note: For validation and global uniqueness enforcement across multiple sets, see the id_registry package.

/// Represents an identifier for an Author, such as name or email.
class AuthorId extends IdPair {
  @override
  final String idType; // e.g., 'name', 'email'
  @override
  final String idCode; // the actual value

  AuthorId(this.idType, this.idCode);

  @override
  List<Object?> get props => [idType, idCode];

  @override
  bool get isValid => idCode.isNotEmpty;

  @override
  String get displayName => '$idType: $idCode';

  @override
  IdPair copyWith({dynamic idType, String? idCode}) {
    return AuthorId(idType as String? ?? this.idType, idCode ?? this.idCode);
  }
}

/// Represents an identifier for a Book, such as ISBN or UPC.
class BookId extends IdPair {
  @override
  final String idType; // e.g., 'isbn', 'upc'
  @override
  final String idCode; // the actual value

  BookId(this.idType, this.idCode);

  @override
  List<Object?> get props => [idType, idCode];

  @override
  bool get isValid => idCode.isNotEmpty;

  @override
  String get displayName => '$idType: $idCode';

  @override
  IdPair copyWith({dynamic idType, String? idCode}) {
    return BookId(idType as String? ?? this.idType, idCode ?? this.idCode);
  }
}

/// Represents an Author entity with multiple identifiers.
class Author {
  final IdPairSet<AuthorId> ids;
  final String name;

  Author(this.name, List<AuthorId> ids) : ids = IdPairSet(ids);

  @override
  String toString() => 'Author(name: $name, ids: ${ids.toString()})';
}

/// Represents a Book entity with multiple identifiers.
class Book {
  final IdPairSet<BookId> ids;
  final String title;

  Book(this.title, List<BookId> ids) : ids = IdPairSet(ids);

  @override
  String toString() => 'Book(title: $title, ids: ${ids.toString()})';
}

/// Manages a collection of Authors and Books.
class Library {
  final List<Author> authors = [];
  final List<Book> books = [];

  /// Adds an author to the library.
  void addAuthor(Author author) {
    authors.add(author);
  }

  /// Adds a book to the library.
  void addBook(Book book) {
    books.add(book);
  }

  /// Removes an author from the library.
  void removeAuthor(Author author) {
    authors.remove(author);
  }

  /// Removes a book from the library.
  void removeBook(Book book) {
    books.remove(book);
  }

  @override
  String toString() {
    return '''
Library:
Authors: ${authors.map((a) => a.name).join(', ')}
Books: ${books.map((b) => b.title).join(', ')}
''';
  }
}

void main() {
  final library = Library();

  // Create authors with multiple IDs
  final author1 = Author('David Foster Wallace', [
    AuthorId('name', 'David Foster Wallace'),
    AuthorId('email', 'dfw@example.com'),
    AuthorId('pseudonym', 'D.F.W.'), // duplicate type, keeps last
  ]);

  final author2 = Author('George R.R. Martin', [
    AuthorId('name', 'George R.R. Martin'),
    AuthorId('email', 'grrm@example.com'),
  ]);

  // Create books with multiple IDs
  final book1 = Book('Infinite Jest', [
    BookId('isbn', '978-0316066525'),
    BookId('upc', '123456789012'),
  ]);

  final book2 = Book('A Game of Thrones', [
    BookId('isbn', '978-0-553-10354-0'),
    BookId('ean', '9780553103540'),
  ]);

  final book3 = Book('The Broom of the System', [
    BookId('isbn', '978-0142180617'),
  ]);

  // Add to library
  library.addAuthor(author1);
  library.addAuthor(author2);
  library.addBook(book1);
  library.addBook(book2);
  library.addBook(book3);

  print('Library:');
  print(library);

  // Demonstrate filtering IDs by type
  print('\nDemonstrating IdPairSet filtering:');
  print('Author1 name IDs: ${author1.ids.getByType('name')}');
  print('Author1 email IDs: ${author1.ids.getByType('email')}');
  print('Author1 pseudonym IDs: ${author1.ids.getByType('pseudonym')}');
  print('Book1 ISBN IDs: ${book1.ids.getByType('isbn')}');
  print('Book1 UPC IDs: ${book1.ids.getByType('upc')}');
  print('Book2 EAN IDs: ${book2.ids.getByType('ean')}');

  // Demonstrate adding duplicate ID types (IdPairSet keeps the last one)
  final authorWithDuplicate = Author('Test Author', [
    AuthorId('name', 'Test Author'),
    AuthorId('name', 'Updated Name'), // This will replace the previous 'name'
  ]);
  print(
    '\nAuthor with duplicate ID type: ${authorWithDuplicate.ids.getByType('name')}',
  );

  // Note: For global uniqueness enforcement, see the id_registry package
}
