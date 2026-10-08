# AGENTS.md — instructions for agents working in this repo

Doctrine: the **Dart/Flutter Bible** (`staylorx/dart-flutter-bible`, canonical
`taybiz/dart-flutter-bible`). Read its `docs/00-compact.md` before touching
anything. The rules live **there** — this file carries only *this repo's*
deviations and local wiring. A second copy of a rule is a second truth (bible
D.R.Y.).

## What this repo is

A single pure-Dart **value library**: immutable id pairs keyed by type, with
explicit duplicate reporting and JSON round-tripping. No Flutter, no I/O, no
app ring. It is a leaf domain value object, not a clean-architecture
application, so the bible's application-ring doctrine (usecases, repositories,
datasources, providers) has no surface here.

## Error style — declared, per the bible

**No exceptions and no FP fault tuples.** Nothing in this package can fail: a
malformed or duplicate entry is a *value* — reported through `duplicates` /
`hasDuplicates`, resolved by `DuplicatePolicy` — never a `throw`, and never an
`Either`/`TaskEither`. Consumers receive plain values. The bible's default
`Future<Either<F, T>>` public seam does not apply because there is no fallible
operation to wrap. This is the deviation the bible asks to be stated loudly;
it is not silence, it is the choice.

## Deviations from the bible (deliberate, not drift)

- **No fpdart / no `Either`** — no fallible operation exists (see above).
- **No usecases, repositories, datasources, or `dart_arch_test` boundary test**
  — one package, no layer boundaries to enforce. Revisit if the package ever
  grows a second package or an I/O adapter.
- **No persistence** — this is a value type; drift/sembast/UoW have no surface.
- The published `example/` is sanctioned (bible: packages get a CI-tested
  `examples/`; this package is on pub.dev).

## Local wiring

- **Layout:** `lib/id_pair_set.dart` is the one hand-written barrel re-exporting
  `lib/src/`; one class per file in `src/`.
- **Gate** (CI runs the same melos scripts a human runs): `melos run
  format-check`, `melos run analyze`, `melos run test`, `melos run example` — or
  `melos run verify` for all of it. Clean = **zero diagnostics of any severity**
  (`dart analyze --fatal-infos --fatal-warnings`).
- **melos:** single-package mode via the root `melos:` key
  (`useRootAsPackage: true`). No `melos.yaml` — banned.
- **Lints:** `analysis_options.yaml` = `lints/recommended` + `todo: error` +
  `public_member_api_docs`.
- **Line endings:** LF in-repo, enforced by `.gitattributes`.
- **Cross-repo:** `id_registry` builds on this package — publish a version here
  first.

## Compliance ledger

`BIBLE_COMPLIANCE.md` is the rule-by-rule matrix and the open-deviation
tracker. Keep it current when the package's conformance changes.
