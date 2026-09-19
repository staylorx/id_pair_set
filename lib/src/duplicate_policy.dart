/// How an `IdPairSet` resolves two pairs that share an id type.
enum DuplicatePolicy {
  /// Keeps the pair seen first; the later pair is reported as a duplicate.
  firstWins,

  /// Keeps the pair seen last; the earlier pair is reported as a duplicate.
  lastWins,
}
