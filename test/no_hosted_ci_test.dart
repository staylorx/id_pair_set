// No-hosted-CI gate — bible §2.10: GitHub is source hosting and pull-request
// review; the build, gate and release are the `melos:` script contract, run by
// us (a human, an agent, or the estate runner). A file under `.github/workflows/`
// is a second definition of "the build" that we neither control nor can run
// locally, so its mere presence is the defect this gate catches.
//
// A rule test, not a behavior test.
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('the repo ships no GitHub Actions workflow', () {
    final workflows = _workflowFiles(_repoRoot());
    if (workflows.isNotEmpty) {
      fail(
        'GitHub Actions workflows found: ${workflows.join(', ')}. Bible §2.10: '
        'GitHub is source hosting and pull-request review; the build, gate and '
        'release are the melos script contract, run from the repo. Delete the '
        'workflow and keep the gate reachable without a hosted runner.',
      );
    }
  });
}

/// The repo root: the nearest ancestor of the test's CWD holding a `.git` entry.
/// `.git` is a directory in a clone and a file in a linked worktree, so both count.
Directory _repoRoot() {
  var dir = Directory.current.absolute;
  while (!File('${dir.path}/.git').existsSync() &&
      !Directory('${dir.path}/.git').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      fail('No .git above ${Directory.current.path}'
          ' — run this test from inside the repo.');
    }
    dir = parent;
  }
  return dir;
}

/// Every workflow file (`.yml`/`.yaml`) under `.github/workflows/`, relative to
/// the repo root, sorted. An absent directory means no workflows.
List<String> _workflowFiles(Directory root) {
  final dir = Directory('${root.path}/.github/workflows');
  if (!dir.existsSync()) return const <String>[];
  return dir
      .listSync()
      .whereType<File>()
      .map((file) => file.path.substring(root.path.length + 1))
      .where((name) => name.endsWith('.yml') || name.endsWith('.yaml'))
      .toList()
    ..sort();
}
