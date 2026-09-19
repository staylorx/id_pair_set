import 'id_pair.dart';

/// The common case: an identifier namespaced by a plain [String].
///
/// Most callers never need their own subclass — use this one.
class SimpleIdPair extends IdPair<String> {
  /// Creates an identifier in the namespace [idType] holding [idCode].
  const SimpleIdPair(this.idType, this.idCode);

  @override
  final String idType;

  @override
  final String idCode;

  @override
  SimpleIdPair copyWith({String? idType, String? idCode}) =>
      SimpleIdPair(idType ?? this.idType, idCode ?? this.idCode);
}
