// ignore_for_file: avoid_print

import 'package:id_pair_set/id_pair_set.dart';

/// Clean Architecture Example: Domain Layer
/// ========================================

/// Represents an identifier for a Book, such as ISBN or LOCAL.
class BookId extends IdPair {
  @override
  final String idType; // e.g., 'isbn', 'local'
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

/// Domain Entity: Book (pure, no external dependencies)
class Book {
  final IdPairSet<BookId> ids;
  final String title;

  Book(this.title, this.ids);

  // Factory method for creation
  static Book create(String title, List<BookId> ids) {
    return Book(title, IdPairSet(ids));
  }

  @override
  String toString() => 'Book(title: $title, ids: ${ids.toString()})';
}

/// Application Layer: Use Cases/Services
/// ======================================

/// Service for managing books with global uniqueness
class BookService {
  final IdRegistry registry;
  final BookRepository repository;

  BookService(this.registry, this.repository);

  /// Adds a book, enforcing global uniqueness
  Future<Book> addBook(String title, List<BookId> ids) async {
    final book = Book.create(title, ids);

    // Register with global uniqueness check
    registry.register(idPairSet: book.ids);

    // Persist if registration succeeds
    await repository.save(book);

    return book;
  }

  /// Removes a book
  Future<void> removeBook(Book book) async {
    registry.unregister(idPairSet: book.ids);
    await repository.delete(book);
  }

  /// Finds a book by ID type and code
  Future<Book?> findBook(String idType, String idCode) async {
    return await repository.findById(idType, idCode);
  }
}

/// Infrastructure Layer: Repository Interface and Implementation
/// ============================================================

/// Repository interface (could be abstracted further)
abstract class BookRepository {
  Future<void> save(Book book);
  Future<void> delete(Book book);
  Future<Book?> findById(String idType, String idCode);
}

/// In-memory implementation for demonstration
class InMemoryBookRepository implements BookRepository {
  final List<Book> _books = [];

  @override
  Future<void> save(Book book) async {
    _books.add(book);
  }

  @override
  Future<void> delete(Book book) async {
    _books.remove(book);
  }

  @override
  Future<Book?> findById(String idType, String idCode) async {
    return _books
        .where(
          (book) => book.ids.idPairs.any(
            (id) => id.idType == idType && id.idCode == idCode,
          ),
        )
        .firstOrNull;
  }
}

/// Main demonstration
void main() async {
  // Infrastructure setup
  final registry = IdRegistry();
  final repository = InMemoryBookRepository();
  final bookService = BookService(registry, repository);

  // Create and add books
  final book1 = await bookService.addBook('Clean Code', [
    BookId('isbn', '978-0132350884'),
    BookId('local', 'LIB001'),
  ]);

  final book2 = await bookService.addBook('Domain-Driven Design', [
    BookId('isbn', '978-0321125217'),
    BookId('local', 'LIB002'),
  ]);

  print('Added books:');
  print(book1);
  print(book2);

  // Try to add duplicate ISBN (should fail)
  print('\nTrying to add book with duplicate ISBN:');
  try {
    await bookService.addBook('Fake Clean Code', [
      BookId('isbn', '978-0132350884'), // Same ISBN
    ]);
  } catch (e) {
    print('Error: $e');
  }

  // Try to add duplicate LOCAL (should fail)
  print('\nTrying to add book with duplicate LOCAL:');
  try {
    await bookService.addBook('Another Book', [
      BookId('local', 'LIB001'), // Same LOCAL
    ]);
  } catch (e) {
    print('Error: $e');
  }

  // Find book by ISBN
  final foundBook = await bookService.findBook('isbn', '978-0132350884');
  print('\nFound book by ISBN: $foundBook');

  // Remove a book
  await bookService.removeBook(book1);
  print(
    '\nAfter removing first book, registered ISBNs: ${registry.getRegisteredCodes(idType: 'isbn')}',
  );
}
