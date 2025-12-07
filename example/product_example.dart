// ignore_for_file: avoid_print

import 'package:id_pair_set/id_pair_set.dart';

/// Example demonstrating basic usage of IdPairSet for managing product identifiers.
/// This example shows how to create an IdPairSet, filter by type, and add new pairs.

/// Represents an identifier for a Product, such as ISBN, UPC, or EAN.
class ProductId extends IdPair {
  @override
  final String idType;
  @override
  final String idCode;

  ProductId(this.idType, this.idCode);

  @override
  List<Object?> get props => [idType, idCode];

  @override
  bool get isValid => idCode.isNotEmpty;

  @override
  String get displayName => '$idType: $idCode';

  @override
  IdPair copyWith({dynamic idType, String? idCode}) {
    return ProductId((idType as String?) ?? this.idType, idCode ?? this.idCode);
  }
}

void main() {
  // Create a list of product IDs, including a duplicate ISBN type
  final ids = [
    ProductId('isbn', '978-3-16-148410-0'),
    ProductId('upc', '123456789012'),
    ProductId(
      'isbn',
      '978-1-23-456789-0',
    ), // duplicate type, keeps last by default
  ];

  // Create an IdPairSet, which automatically removes duplicates by type
  final idSet = IdPairSet(ids);

  print('All IDs: ${idSet.toString()}');
  print('ISBN only: ${idSet.getByType('isbn').toString()}');

  // Add a new EAN identifier
  final withEan = idSet.addPair(ProductId('ean', '1234567890123'));
  print('With EAN: ${withEan.toString()}');
}
