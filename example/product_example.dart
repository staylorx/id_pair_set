import 'dart:io';

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

  stdout.writeln('All IDs: ${idSet.toString()}');
  stdout.writeln('ISBN only: ${idSet.getByType('isbn').toString()}');

  // Add a new EAN identifier
  final withEan = idSet.addPair(ProductId('ean', '1234567890123'));
  stdout.writeln('With EAN: ${withEan.toString()}');

  // Demonstrate ID generation for LOCAL type
  final registry = IdRegistry();
  registry.setGenerationType(
    idType: 'local',
    type: IdGenerationType.autoincrement,
  );

  final localId1 = ProductId('local', registry.generateId(idType: 'local'));
  final localId2 = ProductId('local', registry.generateId(idType: 'local'));

  stdout.writeln(
    'Generated autoincrement LOCAL IDs: ${localId1.idCode}, ${localId2.idCode}',
  );

  // Switch to UUID generation
  registry.setGenerationType(idType: 'local', type: IdGenerationType.uuid);

  final uuidId1 = ProductId('local', registry.generateId(idType: 'local'));
  final uuidId2 = ProductId('local', registry.generateId(idType: 'local'));

  stdout.writeln(
    'Generated UUID LOCAL IDs: ${uuidId1.idCode}, ${uuidId2.idCode}',
  );
}
