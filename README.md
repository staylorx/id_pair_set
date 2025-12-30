# id\_pair\_set

[![pub package](https://img.shields.io/pub/v/id_pair_set.svg)](https://pub.dev/packages/id_pair_set)
[![License](https://img.shields.io/github/license/staylorx/id_pair_set)](https://github.com/staylorx/id_pair_set/blob/main/LICENSE)

A Dart package that provides an efficient way to store and manage sets of ID pairs, ensuring uniqueness by ID type. Ideal for handling multiple identifiers for entities like books (ISBN, UPC, EAN) or products, with built-in immutability and serialization support.

## Features

* **Unique ID Pairs**: Automatically removes duplicates based on `idType`, with options to keep the first or last occurrence.
* **Immutable Operations**: Methods like `addPair` and `removePair` return new instances, maintaining immutability.
* **Type-Based Filtering**: Retrieve pairs by specific `idType` using `getByType`.
* **Serialization**: Convert the set to a sorted string format for storage or comparison (e.g., in databases).
* **Equatable Support**: Built-in equality checks using the `equatable` package.
* **Flexible ID Types**: Supports dynamic `idType` (e.g., String, enum) for versatile use cases.
* **Global Uniqueness Enforcement**: For validation, and (future) global uniqueness across multiple sets, see the `id_registry` package.

## Installation

Add `id_pair_set` to your `pubspec.yaml`:

```yaml
dependencies:
  id_pair_set: ^1.0.0
```

Then run:

```bash
dart pub get
```

Or if using Flutter:

```bash
flutter pub get
```

## Usage

### Implementing IdPair

First, implement the `IdPair` abstract class:

```dart
import 'package:id_pair_set/id_pair_set.dart';

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

### Creating and Managing IdPairSet

Create an `IdPairSet` instance:

```dart
final pairs = [
  MyIdPair('isbn', '978-3-16-148410-0'),
  MyIdPair('upc', '123456789012'),
  MyIdPair('isbn', '978-1-23-456789-0'), // duplicate type, keeps last by default
];

final idSet = IdPairSet(pairs); // keeps last occurrence of duplicates
```

#### Adding Pairs

```dart
final updatedSet = idSet.addPair(MyIdPair('ean', '1234567890123'));
```

#### Removing Pairs

```dart
final pairToRemove = MyIdPair('upc', '123456789012');
final reducedSet = idSet.removePair(pairToRemove);
```

#### Filtering by Type

```dart
final isbnPairs = idSet.getByType('isbn'); // Returns IdPairSet with only ISBN pairs
```

#### Serialization

```dart
print(idSet.toString()); // e.g., "ean:1234567890123|isbn:978-1-23-456789-0|upc:123456789012"
```

#### Keeping First Instead of Last

```dart
final keepFirstSet = IdPairSet(pairs, keepLast: false); // Keeps first occurrence of duplicates
```

### Global Uniqueness

For scenarios requiring uniqueness across multiple `IdPairSet` instances (e.g., ensuring no duplicate ISBNs across all books), use the `id_registry` package.

## API Overview

### IdPair

Abstract base class for ID pairs.

**Properties:**

* `dynamic idType`: The type of the ID (e.g., 'isbn', 'upc').
* `String idCode`: The actual ID code.
* `bool isValid`: Whether the pair is valid.
* `String displayName`: Human-readable representation.

**Methods:**

* `IdPair copyWith({dynamic idType, String? idCode})`: Creates a copy with optional property changes.

### IdPairSet<T extends IdPair>

Immutable set of ID pairs with uniqueness by `idType`.

**Constructor:**

* `IdPairSet(List<T> pairs, {bool keepLast = true})`: Creates a set from a list of pairs. `keepLast` determines whether to keep the last or first duplicate.

**Methods:**

* `IdPairSet<T> addPair(T pair)`: Returns a new set with the pair added.
* `IdPairSet<T> removePair(T pair)`: Returns a new set with the pair removed.
* `IdPairSet<T> getByType(dynamic type)`: Returns a new set containing only pairs of the specified type.
* `String toString()`: Returns a sorted string representation (e.g., "type1:code1|type2:code2").

**Properties:**

* `List<T> idPairs`: The list of unique pairs.
* `bool keepLast`: Whether duplicates keep the last occurrence.

## Contributing

Contributions are welcome! Please see the [contributing guide](https://github.com/staylorx/id_pair_set/blob/main/CONTRIBUTING.md) for details.

## Git Hooks

This project uses [Husky](https://typicode.github.io/husky/) to manage Git hooks. The pre-commit hook automatically formats your Dart code using `dart format .` to ensure consistent code style before each commit.

## Issues and Feedback

If you find a bug or have a feature request, please file an issue on [GitHub](https://github.com/staylorx/id_pair_set/issues).

## Changelog

See the [CHANGELOG.md](https://github.com/staylorx/id_pair_set/blob/main/CHANGELOG.md) for recent changes.

## License

This package is licensed under the MIT License. See [LICENSE](https://github.com/staylorx/id_pair_set/blob/main/LICENSE) for details.
