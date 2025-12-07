import 'package:equatable/equatable.dart';

/// Abstract class for identifier pairs with type and code.
/// Subclasses must implement [idType], [idCode], [isValid], [displayName], and [copyWith].
abstract class IdPair with EquatableMixin {
  /// Creates a new IdPair instance.
  IdPair();

  /// The type of this ID pair.
  dynamic get idType;

  /// The code of this ID pair.
  String get idCode;

  /// Whether this ID pair is valid.
  bool get isValid;

  /// Returns a human-readable string representation of the ID pair.
  String get displayName;

  /// Creates a new instance with optionally modified fields.
  IdPair copyWith({dynamic idType, String? idCode});
}
