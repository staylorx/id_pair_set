import 'package:id_pair_set/id_pair_set.dart';

/// Shows what a set of identifiers is for: gathering every id one thing
/// answers to, and never losing one quietly when two ids claim the same type.
void main() {
  final bookIds = IdPairSet<SimpleIdPair>([
    const SimpleIdPair('isbn', '978-3-16-148410-0'),
    const SimpleIdPair('upc', '123456789012'),
    const SimpleIdPair('ean', '9783161484100'),
  ]);
  print('book: $bookIds');
  print('isbn code: ${bookIds['isbn']?.idCode}');
  print('as json: ${bookIds.toJson()}');
  print('round trips: ${IdPairSet.fromPlainJson(bookIds.toJson()) == bookIds}');

  // One part, named by three authorities, with a second Bally number: the
  // same input list under each duplicate policy.
  const inputs = [
    SimpleIdPair('taybiz', 'SKU-0007'),
    SimpleIdPair('bally', 'A-16486-GLM'),
    SimpleIdPair('stern', '520-5002-00'),
    SimpleIdPair('bally', 'A-16486-GLM-1'),
  ];
  final lastWins = IdPairSet<SimpleIdPair>(inputs);
  final firstWins = IdPairSet<SimpleIdPair>(
    inputs,
    policy: DuplicatePolicy.firstWins,
  );

  print('');
  print('part (lastWins): $lastWins');
  print('  displaced: ${lastWins.duplicates.map((p) => p.displayName)}');
  print('part (firstWins): $firstWins');
  print('  displaced: ${firstWins.duplicates.map((p) => p.displayName)}');
  print('nothing displaced: ${!lastWins.hasDuplicates}');

  // An upsert is deliberate, so it replaces instead of reporting.
  final renumbered = lastWins.add(const SimpleIdPair('bally', 'A-16486-GLM-2'));
  print('');
  print('after upsert: $renumbered');
  print('bally is now: ${renumbered['bally']?.idCode}');
  print('still displaced from the load: ${renumbered.duplicates.length}');
}
