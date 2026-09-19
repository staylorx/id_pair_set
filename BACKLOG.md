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
