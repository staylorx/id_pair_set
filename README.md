# id_pair_set

One thing, many identifiers. `id_pair_set` holds the ids an entity answers to —
an ISBN, a UPC, a manufacturer's part number, your own SKU — as an immutable set
keyed by id type, so each namespace contributes at most one code.

## Why

The same physical thing is named differently by everyone who touches it. A
part number from Bally, another from Stern, a publisher's reference, our own
SKU. Kept as loose strings, those aliases drift into prose and importer code and
nobody can tell whether two ids mean the same object. Kept as pairs keyed by
namespace, the identity is one value: comparable, serializable, and impossible
to duplicate by accident.

## The model

- `IdPair<T>` — one identifier: an `idType` (the namespace) and an `idCode`.
  Equality is both fields, so pairs compare by content. Subclass it when ids
  are keyed by an enum; the type is preserved, not `dynamic`.
- `SimpleIdPair` — the common case, namespaced by a plain string.
- `IdPairSet<T>` — an immutable set holding at most one pair per id type, with
  `operator []` lookup, `contains`/`containsType`/`containsCode`, `add`,
  `addAll`, `remove`, `removeType` and `pairs`/`idTypes`/`length` readers.
- `DuplicatePolicy` — `firstWins` or `lastWins`, applied when two pairs claim
  the same type.

## Guarantees

- **Nothing is dropped quietly.** A pair displaced by a duplicate id type is
  reported by `duplicates` (`hasDuplicates` for the boolean), so a loader can
  refuse the data and a merge can see which occurrence lost. There is no
  keep-silently mode.
- **Equality is by content, not insertion order.** Two sets holding the same
  pairs are equal and hash equal however they were built, so change detection
  and diff gates fire on real changes only.
- **One wire format, and it round-trips.** `toJson` writes a `{idType: idCode}`
  object; `fromPlainJson` reads the string-keyed form back and `fromJson` takes
  a builder for enum-keyed pairs. `toString` is a sorted rendering for logs and
  labels — display only, never parsed.
- **No exceptions.** Nothing here can fail: a malformed entry is a value, not a
  throw, so callers decide what to do with it.

## Usage

The runnable example is `example/main.dart` (CI runs it on every push), and the
tests in `test/` are the reference for every behaviour above.

Add `id_pair_set: ^2.0.0` to your pubspec.

## Upgrading from 1.x

`IdPairSet` was rebuilt in 2.0.0: `dynamic idType` became `IdPair<T>`, the
`keepLast` flag became `DuplicatePolicy`, `idPairs` became `pairs`, `getByType`
became `operator []`, and `toString` is documented as display-only now that
`toJson`/`fromPlainJson` exist. The 2.0.0 section of [CHANGELOG.md](CHANGELOG.md)
lists every rename.

## Related

`id_registry` builds on this package to check uniqueness across many sets.

## License

MIT. See [LICENSE](LICENSE).
