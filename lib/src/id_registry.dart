import 'package:uuid/uuid.dart';

import 'exceptions.dart';
import 'id_pair_set.dart';

/// Enum for specifying how IDs should be generated for a given idType.
enum IdGenerationType {
  /// Generate autoincrementing integer IDs.
  autoincrement,

  /// Generate UUID v4 IDs.
  uuid,
}

/// Registry for managing global uniqueness of all idTypes across multiple IdPairSets.
///
/// This class acts as a "shadow collection" of registered IdPairSets, enforcing uniqueness
/// for all idTypes. It throws DuplicateIdException when attempting to register conflicting
/// identifiers. If uniqueness is not required for certain idTypes, do not use this registry.
class IdRegistry {
  /// Internal registry: idType -> Set of registered idCodes.
  final Map<String, Set<String>> _registry = {};

  /// Generation types for each idType.
  final Map<String, IdGenerationType> _generationTypes = {};

  /// Counters for autoincrement IDs per idType.
  final Map<String, int> _counters = {};

  /// UUID generator instance.
  final Uuid _uuid = Uuid();

  /// Creates an IdRegistry that enforces uniqueness for all idTypes.
  IdRegistry();

  /// Registers an IdPairSet, checking for uniqueness violations.
  ///
  /// Throws [DuplicateIdException] if any idType in the set conflicts
  /// with existing registrations.
  void register({required IdPairSet idPairSet}) {
    for (final pair in idPairSet.idPairs) {
      final idType = pair.idType.toString();
      final codes = _registry.putIfAbsent(idType, () => {});
      if (codes.contains(pair.idCode)) {
        throw DuplicateIdException(idType: idType, idCode: pair.idCode);
      }
      codes.add(pair.idCode);
    }
  }

  /// Unregisters an IdPairSet, removing its identifiers from the registry.
  void unregister({required IdPairSet idPairSet}) {
    for (final pair in idPairSet.idPairs) {
      final idType = pair.idType.toString();
      _registry[idType]?.remove(pair.idCode);
    }
  }

  /// Checks if a specific idType and idCode combination is already registered.
  bool isRegistered({required String idType, required String idCode}) {
    return _registry[idType]?.contains(idCode) ?? false;
  }

  /// Returns all registered idCodes for a given idType.
  Set<String> getRegisteredCodes({required String idType}) {
    return Set.from(_registry[idType] ?? {});
  }

  /// Clears all registrations (useful for testing or resetting).
  void clear() {
    _registry.clear();
    _generationTypes.clear();
    _counters.clear();
  }

  /// Sets the ID generation type for a given idType.
  void setGenerationType({
    required String idType,
    required IdGenerationType type,
  }) {
    _generationTypes[idType] = type;
  }

  /// Generates the next ID for the given idType based on its generation type.
  ///
  /// For [IdGenerationType.autoincrement], returns an incrementing integer as string.
  /// For [IdGenerationType.uuid], returns a new UUID v4.
  String generateId({required String idType}) {
    final type = _generationTypes[idType];
    if (type == null) {
      throw UnsupportedError('No generation type set for $idType');
    }
    switch (type) {
      case IdGenerationType.autoincrement:
        final counter = _counters[idType] ?? 0;
        _counters[idType] = counter + 1;
        return counter.toString();
      case IdGenerationType.uuid:
        return _uuid.v4();
    }
  }
}
