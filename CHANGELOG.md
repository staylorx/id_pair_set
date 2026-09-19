## 2.0.0 - 2026-09-19

Rebuilt so a catalog, a loader or a diff gate can trust the value.

### Added
- `IdPair<T>` — the id type keeps its static type (an enum, a string), replacing
  the `dynamic` getter. `props` is implemented by the base, so subclasses only
  override what they add.
- `SimpleIdPair` — the concrete string-keyed pair, so the common case needs no
  subclass.
- `toJson`, `IdPairSet.fromJson` (with a pair builder) and
  `IdPairSet.fromPlainJson` — a wire format that round-trips, replacing the
  unparseable `toString`.
- `duplicates` and `hasDuplicates` — every pair displaced by a duplicate id
  type is reported instead of vanishing.
- `DuplicatePolicy` (`firstWins` / `lastWins`) — the duplicate rule is named
  rather than a bare boolean.
- `operator []`, `contains`, `containsCode`, `containsType`, `idTypes`,
  `length`, `isEmpty`, `isNotEmpty`, `policy`, `pairs`.
- `remove` (exact pair) and `removeType` (whatever code a type held).
- `idTypeKey` — the one definition of how an id type is named on the wire, so a
  stored key and a looked-up key cannot drift.

### Changed
- Equality and `hashCode` are order-insensitive: two sets holding the same
  pairs are equal however they were built. Previously a no-op `addPair` of an
  identical pair reordered the set and broke equality while `toString` stayed
  identical.
- `add` is an explicit upsert: the incoming pair wins for its type.
- `toString` is documented as a display rendering, not a wire format (a code
  may contain the `:` and `|` separators).
- SDK constraint is now `>=3.10.0 <4.0.0`; `equatable ^2.1.0` (the deprecated
  `EquatableMixin` is gone, so the package analyzes clean at `--fatal-infos`).

### Removed
- `idPairs` (renamed `pairs`), `getByType` (replaced by `operator []` and
  `pairs`), `keepLast` (replaced by `DuplicatePolicy`), and `addPair` /
  `removePair` (renamed `add` / `remove`).

## 1.2.0 - 2025-12-30

### Removed
- `IdRegistry` and `DuplicateIdException` moved to the `id_registry` package.

### Changed
- Documentation now points at `id_registry` for cross-set uniqueness.

## 1.1.0 - 2025-12-30

### Added
- `IdRegistry` for global uniqueness across `IdPairSet`s, plus
  `DuplicateIdException` and a clean-architecture example.

## 1.0.3 - 2025-12-06

### Changed
- Documentation. I _really_ want those pub.dev points.

## 1.0.2 - 2025-12-06

### Changed
- Documentation.

## 1.0.1 - 2025-12-06

### Changed
- Documentation.

## 1.0.0 - 2025-12-06

### Added
- Initial release: `IdPair`, `IdPairSet`, add/remove/filter by type, a sorted
  `toString`, and `equatable` equality.
