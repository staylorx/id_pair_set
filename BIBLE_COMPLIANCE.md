# Bible compliance ledger — id_pair_set

Rule-by-rule status against the Dart/Flutter Bible
(`docs/00-compact.md`, canonical `taybiz/dart-flutter-bible`). Legend:
✅ conforms · 🔧 fixed in this pass · ⚠️ deliberate deviation (declared) ·
❌ open gap · ➖ not applicable (no surface in this package).

This package is a single pure-Dart **value library**. Rules for the application
ring (usecases, repositories, datasources, Flutter, persistence) have no surface
here; they are marked ➖, not ❌, and are revisited if the package grows layers.

Open deviations with a code change behind them are tracked in `BACKLOG.md`
(§ "Build + Bible audit") and referenced below rather than duplicated.

## Architecture & failure

| Rule | Status | Where it stands |
| --- | --- | --- |
| Onion / inward dependencies | ➖ | Leaf value lib — no layers, no cross-layer imports. |
| Failure is a value outside the UI ring | ✅ | No `throw` in the package; malformed entries are values. |
| fpdart `Either`/`TaskEither` seam | ⚠️ | No fallible operation exists to wrap — declared in AGENTS.md, barrel, README. |
| `equatable` on entities/value objects | ✅ | `IdPair` (mixin) and `IdPairSet` both `Equatable`, `props` implemented. |
| Sealed per-layer failure hierarchies | ➖ | No failures to model. |
| `tryCatch` only at adapter boundaries | ➖ | No adapters. |
| ≥2 repository adapters + shared contract suite | ➖ | No repositories. |

## Declarations & docs

| Rule | Status | Where it stands |
| --- | --- | --- |
| Error style declared loudly (barrel + README + AGENTS) | 🔧 | Barrel doc comment, README intro, and AGENTS.md now all declare it. |
| Terse `///` on declarations and members | ✅ | Every public declaration and member documented; no file-header `///` except the barrel (which has `library;`). |
| `public_member_api_docs` ON | ✅ | `analysis_options.yaml`; enforced in the analyze gate. |
| D.R.Y. — no restated rules in README/AGENTS | ✅ | AGENTS.md points at the bible; README orients, states no architecture rules. |
| Code placement: tests first, `examples/` for packages | ⚠️ | Behaviours live in `test/`; the example is `example/main.dart` (singular, the pub.dev convention) — BACKLOG asks whether doctrine means `examples/`. |

## Toolchain & enforcement

| Rule | Status | Where it stands |
| --- | --- | --- |
| SDK constraint `>=3.10.0 <4.0.0` | ✅ | `pubspec.yaml`. |
| One class per file; one hand-written barrel | ✅ | `lib/src/*` one class each; `lib/id_pair_set.dart` re-exports `src/`. |
| `dart format`/`analyze`/`test` only, no src/ cross-imports | ✅ | Gate green; no external `src/` imports. |
| No `melos.yaml`; melos optional single-package runner | ✅ | Root `melos:` key, `useRootAsPackage: true`; no `melos.yaml` file. |
| `todo: error` in analysis_options | ✅ | `analysis_options.yaml`. |
| Strict analyzer (`strict-casts`/`strict-inference`/`strict-raw-types`) | ⚠️ | Bible §9 step 8's "strict" half is unmet — no `language:` block. Code change; see BACKLOG. |
| CLEAN = zero diagnostics of any severity | ✅ | `dart analyze --fatal-infos --fatal-warnings` → "No issues found!". |
| Per-line ignores only | ✅ | No `// ignore:` and no `ignore_for_file` in the package. |
| No TODO/FIXME in code | ✅ | None in `lib/`, `test/`, `example/` (roadmap lives in `BACKLOG.md`). |
| CI runs analyze + test on every PR | ✅ | `.github/workflows/ci.yml` runs the melos scripts. |
| LF in-repo via `.gitattributes` | ✅ | Landed in the prior pass (`* text=auto eol=lf`); tree already all-LF. |
| `dart_arch_test` boundary + cycle test | ➖ | Single package — no boundaries. BACKLOG asks for the cycle-freedom half or a doctrine exemption written in. |
| Params business-shaped, positional only for `ref`/`message` | ⚠️ | `SimpleIdPair(idType, idCode)`, `IdPairSet(pairs, {policy})`, `pairFromJson(idType, idCode)` take positional params. Code change; see BACKLOG. |

## Testing & stack

| Rule | Status | Where it stands |
| --- | --- | --- |
| shouldly (`x.should.be(...)`), never `expect` | ✅ | Both test files import only shouldly. |
| Given/When/Then test names | ⚠️ | Most groups are GWT; a few are Given/Then with no trigger to name. See BACKLOG. |
| Test both `Either` sides per usecase | ➖ | No `Either`; both duplicate policies are covered instead. |
| Pinned stack (fpdart, drift, sembast, riverpod, go_router, mocktail) | ➖ | Not used; `equatable` and shouldly are. |
| Banned builders (freezed, json_serializable, …) | ✅ | None present. |
| `equatable` pin `^2.x` | ✅ | On `^2.1.0` per doctrine; 3.0.0 exists upstream — the doctrine pin is behind the ecosystem. Decided: stay. |

## Open items

Everything with a code change behind it is a `BACKLOG.md` entry, not fixed here:
positional params, the strict-analyzer block, the architecture test, example
directory naming, and Given/Then group names. Fixed in this pass: the error-style
declaration (barrel + README + AGENTS.md), `AGENTS.md`, and this ledger.
