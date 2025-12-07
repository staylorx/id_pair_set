import 'package:equatable/equatable.dart';
import 'id_pair.dart';

/// An immutable set of unique [IdPair] instances, keyed by type.
class IdPairSet<T extends IdPair> with EquatableMixin {
  /// The list of unique ID pairs in this set.
  final List<T> idPairs;

  /// Whether to keep the last occurrence of duplicate ID types; true by default.
  final bool keepLast;

  /// Creates an [IdPairSet] from a list of pairs, ensuring uniqueness.
  IdPairSet(List<T> pairs, {this.keepLast = true})
    : idPairs = _unique(pairs, keepLast);

  /// Returns a list of unique pairs, keeping the last occurrence if [keepLast] is true.
  static List<T> _unique<T extends IdPair>(List<T> pairs, bool keepLast) {
    final uniquePairs = <dynamic, T>{};

    if (keepLast) {
      for (final pair in pairs) {
        uniquePairs[pair.idType] = pair;
      }
    } else {
      for (final pair in pairs) {
        if (!uniquePairs.containsKey(pair.idType)) {
          uniquePairs[pair.idType] = pair;
        }
      }
    }

    return uniquePairs.values.toList();
  }

  /// Returns a new IdPairSet with the specified pair added.
  IdPairSet<T> addPair(T pair) {
    if (keepLast) {
      return IdPairSet([
        ...idPairs.where((p) => p.idType != pair.idType),
        pair,
      ], keepLast: keepLast);
    } else {
      if (idPairs.any((p) => p.idType == pair.idType)) {
        return this;
      }
      return IdPairSet([...idPairs, pair], keepLast: keepLast);
    }
  }

  /// Returns a new IdPairSet with the specified pair removed.
  IdPairSet<T> removePair(T pair) {
    return IdPairSet(
      idPairs.where((p) => p != pair).toList(),
      keepLast: keepLast,
    );
  }

  /// Returns a new IdPairSet containing only pairs with the specified idType.
  IdPairSet<T> getByType(dynamic type) {
    return IdPairSet(
      idPairs.where((p) => p.idType == type).toList(),
      keepLast: keepLast,
    );
  }

  /// Returns a string representation in the format "type:code|type:code|...".
  @override
  String toString() {
    if (idPairs.isNotEmpty) {
      final sorted = List<T>.from(idPairs)
        ..sort((a, b) => a.idType.toString().compareTo(b.idType.toString()));
      return sorted.map((p) => '${p.idType.toString()}:${p.idCode}').join('|');
    } else {
      return '';
    }
  }

  @override
  List<Object?> get props => [idPairs];
}
