import 'package:equatable/equatable.dart';
import 'id_pair.dart';

class IdPairSet<T extends IdPair> with EquatableMixin {
  final List<T> idPairs;
  final bool keepLast;

  IdPairSet(List<T> pairs, {this.keepLast = true})
    : idPairs = _unique(pairs, keepLast);

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

  /// Returns a unique string identifier for this IdPairSet, derived from its contents.
  /// The format is "idType1:idCode1|idType2:idCode2|...". Pairs are sorted by idType.
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
