## [1.1.0] - 2025-12-30

### Added
- `IdRegistry` class for managing global uniqueness of ID pairs across multiple `IdPairSet` instances.
- `DuplicateIdException` for handling conflicts when registering duplicate IDs.
- New clean architecture example demonstrating advanced usage.

### Changed
- Updated documentation and examples for better clarity.

## [1.0.3] - 2025-12-06

### Changed
- Updated documentation. I _really_ want those pub.dev points.

## [1.0.2] - 2025-12-06

### Changed
- Updated documentation.

## [1.0.1] - 2025-12-06

### Changed
- Updated documentation.

## [1.0.0] - 2025-12-06

### Added
- Initial release of `id_pair_set` package.
- `IdPair` abstract class for representing ID pairs with type and code.
- `IdPairSet` class for efficiently storing and managing collections of ID pairs.
- Support for unique pairs with configurable behavior (keep last or first occurrence).
- Methods for adding, removing, and filtering pairs by type.
- `toString()` method for consistent serialization and identification.
- Integration with `equatable` for equality comparisons.
