import 'package:equatable/equatable.dart';

/// Represents a pair of identifiers consisting of an ID type and an ID code.
///
/// This abstract class serves as the building block for managing collections of unique
/// identifier pairs in the `id_pair_set` package. Subclasses must implement
/// [idType], [idCode], [isValid], [displayName], and [copyWith].
abstract class IdPair with EquatableMixin {
  dynamic get idType;
  String get idCode;
  bool get isValid;
  /// Returns a human-readable string representation of the ID pair.
  String get displayName;
  
  /// Creates a new instance with optionally modified fields.
  IdPair copyWith({dynamic idType, String? idCode});
}
