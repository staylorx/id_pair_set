import 'exceptions.dart';
import 'id_pair_set.dart';

/// Registry for managing global uniqueness of all idTypes across multiple IdPairSets.
///
/// This class acts as a "shadow collection" of registered IdPairSets, enforcing uniqueness
/// for all idTypes. It throws DuplicateIdException when attempting to register conflicting
/// identifiers. If uniqueness is not required for certain idTypes, do not use this registry.
class IdRegistry {
  /// Internal registry: idType -> Set of registered idCodes.
  final Map<String, Set<String>> _registry = {};

  /// Creates an IdRegistry that enforces uniqueness for all idTypes.
  IdRegistry();

  /// Registers an IdPairSet, checking for uniqueness violations.
  ///
  /// Throws [DuplicateIdException] if any idType in the set conflicts
  /// with existing registrations.
  void register(IdPairSet set) {
    for (final pair in set.idPairs) {
      final idType = pair.idType.toString();
      final codes = _registry.putIfAbsent(idType, () => {});
      if (codes.contains(pair.idCode)) {
        throw DuplicateIdException(idType: idType, idCode: pair.idCode);
      }
      codes.add(pair.idCode);
    }
  }

  /// Unregisters an IdPairSet, removing its identifiers from the registry.
  void unregister(IdPairSet set) {
    for (final pair in set.idPairs) {
      final idType = pair.idType.toString();
      _registry[idType]?.remove(pair.idCode);
    }
  }

  /// Checks if a specific idType and idCode combination is already registered.
  bool isRegistered(String idType, String idCode) {
    return _registry[idType]?.contains(idCode) ?? false;
  }

  /// Returns all registered idCodes for a given idType.
  Set<String> getRegisteredCodes(String idType) {
    return Set.from(_registry[idType] ?? {});
  }

  /// Clears all registrations (useful for testing or resetting).
  void clear() {
    _registry.clear();
  }
}
