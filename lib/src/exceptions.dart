/// Exception thrown when attempting to register an IdPairSet with duplicate unique identifiers.
class DuplicateIdException implements Exception {
  /// The type of the duplicate ID.
  final String idType;

  /// The code of the duplicate ID.
  final String idCode;

  /// Creates a DuplicateIdException with the given [idType] and [idCode].
  DuplicateIdException({required this.idType, required this.idCode});

  @override
  String toString() =>
      'DuplicateIdException: $idType:$idCode already exists in registry';
}
