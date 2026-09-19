import 'package:equatable/equatable.dart';

import 'duplicate_policy.dart';
import 'id_pair.dart';
import 'id_type_key.dart';
import 'simple_id_pair.dart';

/// An immutable set of [IdPair]s holding at most one id per id type.
///
/// Nothing is dropped quietly: a pair displaced by a duplicate id type is
/// reported by [duplicates], so a loader can refuse the data while a merge can
/// see which occurrence lost. Equality is by content, not by insertion order.
class IdPairSet<T extends IdPair<Object>> extends Equatable {
  /// Builds a set from [pairs], resolving a repeated id type with [policy].
  factory IdPairSet(
    Iterable<T> pairs, {
    DuplicatePolicy policy = DuplicatePolicy.lastWins,
  }) {
    final byType = <Object, T>{};
    final duplicates = <T>[];
    for (final pair in pairs) {
      final existing = byType[pair.idType];
      if (existing == null) {
        byType[pair.idType] = pair;
        continue;
      }
      if (policy == DuplicatePolicy.lastWins) {
        duplicates.add(existing);
        byType[pair.idType] = pair;
      } else {
        duplicates.add(pair);
      }
    }
    return IdPairSet<T>._(byType, duplicates, policy);
  }

  /// Builds a string-keyed set from a `{idType: idCode}` JSON object.
  static IdPairSet<SimpleIdPair> fromPlainJson(
    Map<String, dynamic> json, {
    DuplicatePolicy policy = DuplicatePolicy.lastWins,
  }) {
    final pairs = <SimpleIdPair>[];
    for (final entry in json.entries) {
      final code = _codeFromWire(entry.value);
      if (code == null) continue;
      pairs.add(SimpleIdPair(entry.key, code));
    }
    return IdPairSet<SimpleIdPair>(pairs, policy: policy);
  }

  /// Builds a set from a `{idType: idCode}` JSON object, one pair per entry.
  ///
  /// [pairFromJson] maps the stored type key and code back onto the pair type —
  /// the key is an enum's value name, or `toString()` for any other type;
  /// entries whose value is null are skipped.
  factory IdPairSet.fromJson(
    Map<String, dynamic> json, {
    required T Function(String idType, String idCode) pairFromJson,
    DuplicatePolicy policy = DuplicatePolicy.lastWins,
  }) {
    final pairs = <T>[];
    for (final entry in json.entries) {
      final code = _codeFromWire(entry.value);
      if (code == null) continue;
      pairs.add(pairFromJson(entry.key, code));
    }
    return IdPairSet<T>(pairs, policy: policy);
  }

  IdPairSet._(this._byType, this._duplicates, this._policy);

  final Map<Object, T> _byType;
  final List<T> _duplicates;
  final DuplicatePolicy _policy;

  /// The policy applied when two pairs share an id type.
  DuplicatePolicy get policy => _policy;

  /// The pairs held, in first-seen id type order.
  List<T> get pairs => List<T>.unmodifiable(_byType.values);

  /// Every pair displaced by a duplicate id type, in the order it was seen.
  List<T> get duplicates => List<T>.unmodifiable(_duplicates);

  /// Whether any pair was displaced by a duplicate id type.
  bool get hasDuplicates => _duplicates.isNotEmpty;

  /// The id types held, in first-seen order.
  List<Object> get idTypes => List<Object>.unmodifiable(_byType.keys);

  /// The number of pairs held.
  int get length => _byType.length;

  /// Whether the set holds no pairs.
  bool get isEmpty => _byType.isEmpty;

  /// Whether the set holds at least one pair.
  bool get isNotEmpty => _byType.isNotEmpty;

  /// The pair registered under [idType], or null when that type is absent.
  T? operator [](Object idType) => _byType[idType];

  /// Whether a pair is registered under [idType].
  bool containsType(Object idType) => _byType.containsKey(idType);

  /// Whether [pair] is registered, matched on id type and code together.
  bool contains(T pair) => _byType[pair.idType] == pair;

  /// Whether any registered pair carries [idCode], whatever its type.
  bool containsCode(String idCode) =>
      _byType.values.any((pair) => pair.idCode == idCode);

  /// Returns a set holding [pair], replacing any pair of the same id type.
  IdPairSet<T> add(T pair) =>
      IdPairSet<T>._({..._byType, pair.idType: pair}, _duplicates, _policy);

  /// Returns a set holding every pair in [pairs], later pairs winning by type.
  IdPairSet<T> addAll(Iterable<T> pairs) =>
      pairs.fold(this, (set, pair) => set.add(pair));

  /// Returns a set without [pair], matched on id type and code together.
  IdPairSet<T> remove(T pair) {
    if (_byType[pair.idType] != pair) return this;
    return removeType(pair.idType);
  }

  /// Returns a set without whatever pair is registered under [idType].
  IdPairSet<T> removeType(Object idType) {
    if (!_byType.containsKey(idType)) return this;
    final next = Map<Object, T>.of(_byType)..remove(idType);
    return IdPairSet<T>._(next, _duplicates, _policy);
  }

  /// Encodes the set as a JSON object of `{idType: idCode}`.
  ///
  /// An enum id type is written as its value name (`bally`), anything else as
  /// `toString()`, so keys are unique as long as the types mixed into one set
  /// do not share a name.
  Map<String, dynamic> toJson() => {
    for (final entry in _byType.entries)
      idTypeKey(idType: entry.key): entry.value.idCode,
  };

  /// A stable rendering of `type:code` joined by `|`.
  ///
  /// Display only — a code may contain the separators, so this is not a wire
  /// format. Use [toJson] to persist a set and [fromPlainJson] to read it back.
  @override
  String toString() {
    final entries = _byType.entries.toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
    return entries.map((e) => '${e.key}:${e.value.idCode}').join('|');
  }

  @override
  List<Object?> get props => [Map<Object, T>.unmodifiable(_byType)];
}

/// Reads a stored code, treating a missing entry as absent rather than empty.
String? _codeFromWire(Object? value) => value == null ? null : '$value';
