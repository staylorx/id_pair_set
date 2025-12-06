# id_pair_set

A Dart package that provides an efficient way to store and manage sets of ID pairs, ensuring uniqueness by ID type.

## Features

- **Unique ID Pairs**: Automatically removes duplicates based on `idType`, with options to keep the first or last occurrence.
- **Immutable Operations**: Methods like `addPair` and `removePair` return new instances, maintaining immutability.
- **Type-Based Filtering**: Retrieve pairs by specific `idType` using `getByType`.
- **Serialization**: Convert the set to a sorted string format for storage or comparison (e.g., in databases).
- **Equatable Support**: Built-in equality checks using the `equatable` package.

## Getting Started

Add `id_pair_set` to your `pubspec.yaml`:

```yaml
dependencies:
  id_pair_set: ^1.0.0
```

Import the package:

```dart
import 'package:id_pair_set/id_pair_set.dart';
```

## Usage

First, implement the `IdPair` abstract class:

```dart
class MyIdPair extends IdPair {
  @override
  final String idType;
  @override
  final String idCode;

  MyIdPair(this.idType, this.idCode);

  @override
  List<Object?> get props => [idType, idCode];

  @override
  bool get isValid => idCode.isNotEmpty;

  @override
  String get displayName => '$idType: $idCode';

  @override
  IdPair copyWith({dynamic idType, String? idCode}) {
    return MyIdPair(idType ?? this.idType, idCode ?? this.idCode);
  }
}
```

Create and manage an `IdPairSet`:

```dart
final pairs = [
  MyIdPair('isbn', '978-3-16-148410-0'),
  MyIdPair('upc', '123456789012'),
  MyIdPair('isbn', '978-1-23-456789-0'), // duplicate type, keeps last
];

final idSet = IdPairSet(pairs); // keeps last by default

// Add a new pair
final updatedSet = idSet.addPair(MyIdPair('ean', '1234567890123'));

// Get pairs by type
final isbnPairs = idSet.getByType('isbn');

// Serialize to string
print(idSet.toString()); // e.g., "ean:1234567890123|isbn:978-1-23-456789-0|upc:123456789012"
```

## Additional Information

This package is useful for scenarios where you need to handle multiple identifiers for entities (e.g., books with ISBN, UPC, EAN codes) and ensure no duplicates by type. The `keepLast` parameter controls whether to keep the first or last pair when duplicates are encountered.