# Backlog or Bugs

When complete, mark each off and include a sentence as to disposition.

- [ ] **Publish 2.0.0** (`dart pub publish` from the repo root). Blocked on
  publisher credentials — the packaging is verified by the CI publish dry-run,
  so the publish itself is the only step left. `id_registry` depends on this
  version, so it must be published first.

- [ ] **Consumers.** Nothing in the estate imports this package yet. The
  intended first consumer is a catalog layer that records several authorities'
  ids for one part (bally / stern / ours), and `id_registry` downstream.

- [ ] **Consider a `source` per pair.** A catalog's alias claims carry where the
  claim came from ("Mousin' Around manual, 1989"). A pair currently has no
  provenance field; adding one is a wire-format change and would need 3.0.0.

- [ ] **Decide the fate of `id_registry`'s generation feature** — see that
  repo's backlog. Auto-increment ids for a generic identifier set are only
  useful where one writer owns the namespace.

## Build + Bible audit — 2026-09-24 (Windows lane, Dart SDK 3.13.1)

Gate: `dart pub get`, `dart format --output=none --set-exit-if-changed .`,
`dart analyze --fatal-infos --fatal-warnings`, `dart test`, `dart run
example/main.dart`, `dart pub publish --dry-run` — every step exit 0, analyzer
reports zero diagnostics of any severity, publish dry-run reports 0 warnings.
**No build, lint, test or dependency problem found on this platform.** The items
below are audit findings against the Dart/Flutter Bible, each flagged for later
review and deliberately not auto-fixed, because a deviation is a place where the
code and the Bible disagree and either side may be the wrong one.

- [ ] **Deviation: lib/id_pair_set.dart** - the barrel's doc comment says what
  the package holds but not which error style consumers get. Bible §4 ("Declare
  the error style, loudly") requires the barrel to name it; for this package the
  honest wording is "no fallible calls — nothing here throws" (README already
  states the behaviour, but not as the declaration). The Bible has no wording
  yet for a package with no failure paths, which may be the real gap.

- [ ] **Deviation: README.md** - same missing declaration near the top, where
  Bible §4 puts it so it is read before the first call is written. The "No
  exceptions" line sits far below, under Guarantees, as a behaviour bullet
  rather than a named style.

- [ ] **Deviation: (missing) AGENTS.md** - Bible §4 requires AGENTS.md to carry
  the error-style declaration whenever a package deviates from the
  `Future<Either<Failure, T>>` default. This package deviates in the strongest
  way (it presents neither tuples nor exceptions) and ships no AGENTS.md, so the
  deviation is currently undeclared at the repo level.

- [ ] **Deviation: lib/src/simple_id_pair.dart** - `SimpleIdPair(this.idType,
  this.idCode)` takes two positional parameters; Bible §2/§4 allow positional
  parameters only for a single `ref`/`message`. The same shape repeats in
  `IdPairSet(pairs, {policy})` (positional iterable), the
  `pairFromJson(String idType, String idCode)` callback in
  `IdPairSet.fromJson`, and the `KeyedId` fixtures in both test files.

- [ ] **Deviation: example/** - Bible §2/§10 name the package example directory
  `examples/` (plural) and make it the sanctioned home for package example code.
  This repo ships `example/main.dart` (singular), which is the pub.dev
  convention. Worth settling which one the doctrine means.

- [ ] **Deviation: analysis_options.yaml** - Bible §9 step 8 asks for "lints,
  strict, public_member_api_docs, todo: error". This file sets
  `lints/recommended`, `public_member_api_docs: true` and `todo: error`, but no
  `language:` block, so `strict-casts` / `strict-inference` / `strict-raw-types`
  are off and the "strict" half of the checklist is unmet.

- [ ] **Deviation: test/id_pair_set_test.dart** - Bible §6 names tests
  Given/When/Then; several groups here are Given/Then ("Given an IdPairSet built
  from distinct types" → "Then it holds …") because there is no trigger to name.
  Either the naming rule should allow an implicit When, or these groups get one.

- [ ] **Deviation: (missing) test/architecture_test.dart** - Bible §2 and §9
  step 7 make a `dart_arch_test` boundary + cycle test the CI hard gate over the
  resolved import graph. The repo has neither. With a single package there are no
  package boundaries to assert, so this needs either the cycle-freedom half or an
  explicit single-package exemption written into the Bible.

- [ ] **Deviation: pubspec.yaml** - `equatable: ^2.1.0` is pinned while 3.0.0 is
  the latest release (`dart pub outdated`). The Bible's STACK pins `equatable
  ^2.x`, so the code follows doctrine and the doctrine is what is behind the
  ecosystem. Decided: stay on ^2.x until the pin is revised (see CHANGELOG.md).

- [ ] **Transitive dependency held back.** `platform` resolves to 3.1.6 with
  3.2.0 available; it arrives through the dev-dependency graph (`melos` / `test`)
  and is not a direct dependency, so nothing to do until those move. Re-check on
  the next toolchain bump.

- [ ] **No `.gitattributes`.** The repo sets no git-level line-ending policy, so
  a Windows checkout that renormalizes would commit CRLF for every file. Add
  `* text=auto eol=lf` plus one `git add --renormalize .` pass. Not a Bible rule
  — it is this shop's house rule, so it belongs in its own commit rather than
  folded into a docs change.
