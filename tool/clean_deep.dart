// Deep clean of generated artifacts for the id_pair_set package.
//
// Removes the generated/ignored artifact directories -- .dart_tool/, build/,
// and .logs/ -- at the package root. Does NOT touch pubspec.lock (it is
// ignored via .gitignore and deliberately preserved).
//
// This is a TARGETED clean: it only ever deletes generated artifact dirs. It
// deliberately does NOT run `git clean` and never touches source, pubspec.yaml,
// .gitignore, AGENTS.md, or .idea/.
//
// Cross-platform by construction (pure dart:io), so the same script works on
// Windows and POSIX regardless of the active shell.
//
// Usage (from the package root, normally via `melos run clean:deep`):
//   dart run tool/clean_deep.dart
//
// Calling it with the root argument is safe: it is a no-op for unrelated
// directories.

import 'dart:io';

/// The generated-artifact directory names this clean removes.
const _targets = <String>{'.dart_tool', 'build', '.logs'};

int _removed = 0;

/// Deletes [dir] recursively if it exists; returns true when something was
/// removed.
bool _removeIfPresent(Directory dir) {
  if (!dir.existsSync()) {
    return false;
  }
  try {
    dir.deleteSync(recursive: true);
    _removed++;
    stdout.writeln('removed  ${dir.path}');
    return true;
  } on FileSystemException catch (e) {
    stderr.writeln('WARNING: could not remove ${dir.path}: ${e.message}');
    return false;
  }
}

/// Removes the artifact dirs under the directory at [path].
void _cleanTreeAt(String path) {
  for (final name in _targets) {
    _removeIfPresent(Directory('$path${Platform.pathSeparator}$name'));
  }
}

void main(List<String> args) {
  final root = Directory(File.fromUri(Platform.script).parent.parent.path);
  if (args.isNotEmpty) {
    final arg = args.first;
    if (arg == '-h' || arg == '--help') {
      stdout.writeln(
          'Removes .dart_tool/, build/, .logs/ at the package root.');
      return;
    }
  }
  if (!File('${root.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
    stderr.writeln('clean_deep: ${root.path} is not a Dart package root '
        '(no pubspec.yaml). Run this from the package root.');
    exitCode = 1;
    return;
  }

  stdout.writeln('Deep clean: ${root.path}');
  _cleanTreeAt(root.path);
  stdout.writeln('Removed $_removed artifact director'
      '${_removed == 1 ? 'y' : 'ies'}.');
}
