import 'package:equatable/equatable.dart';

/// One identifier for one thing: a namespace ([idType]) and the code it holds.
///
/// Equality is [idType] plus [idCode], so pair values compare by content.
/// Subclass it when ids are keyed by something other than a plain string — an
/// enum of namespaces, for instance.
abstract class IdPair<T extends Object> with Equatable {
  /// Allows subclasses to be created by const constructors.
  const IdPair();

  /// The namespace this id belongs to, e.g. `isbn`, `bally`, or an enum value.
  T get idType;

  /// The identifier itself, written the way its authority writes it.
  String get idCode;

  /// Whether [idCode] carries a value; override to add format-level rules.
  bool get isValid => idCode.trim().isNotEmpty;

  /// Human-readable form for logs, labels and tooltips.
  String get displayName => '$idType: $idCode';

  /// Returns a copy with [idType] and/or [idCode] replaced.
  IdPair<T> copyWith({T? idType, String? idCode});

  @override
  List<Object?> get props => [idType, idCode];
}
