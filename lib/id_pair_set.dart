/// Identifiers keyed by namespace, with explicit duplicate reporting.
///
/// Error style: this package throws nothing and returns no fault tuples — a
/// malformed or duplicate entry is a *value*, reported through `duplicates` and
/// resolved by `DuplicatePolicy`. See `AGENTS.md`.
library;

export 'src/duplicate_policy.dart';
export 'src/id_pair.dart';
export 'src/id_pair_set.dart';
export 'src/id_type_key.dart';
export 'src/simple_id_pair.dart';
