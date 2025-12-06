import 'package:id_pair_set/id_pair_set.dart';
import 'package:test/test.dart';

// Concrete implementation for testing IdPair
class TestIdPair extends IdPair {
  @override
  final String idType;
  @override
  final String idCode;

  TestIdPair(this.idType, this.idCode);

  @override
  List<Object?> get props => [idType, idCode];

  @override
  bool get isValid => idCode.isNotEmpty;

  @override
  String get displayName => '$idType: $idCode';

  @override
  IdPair copyWith({dynamic idType, String? idCode}) {
    return TestIdPair((idType as String?) ?? this.idType, idCode ?? this.idCode);
  }
}

void main() {
  group('IdPairSet', () {
    test('constructor creates IdPairSet with given pairs', () {
      final pairs = [TestIdPair('isbn', '123'), TestIdPair('upc', '456')];
      final idSet = IdPairSet(pairs);

      expect(idSet.idPairs, equals(pairs));
    });

    test('equality works correctly', () {
      final pairs1 = [TestIdPair('isbn', '123'), TestIdPair('upc', '456')];
      final pairs2 = [TestIdPair('isbn', '123'), TestIdPair('upc', '456')];
      final idSet1 = IdPairSet(pairs1);
      final idSet2 = IdPairSet(pairs2);

      expect(idSet1, equals(idSet2));
    });

    test('removes duplicate pairs', () {
      final pairs = [
        TestIdPair('ISBN', '123'),
        TestIdPair('UPC', '456'),
        TestIdPair('ISBN', '123'), // duplicate
        TestIdPair('EAN', '789'),
      ];
      final idSet = IdPairSet(pairs);

      expect(idSet.idPairs.length, 3);
      expect(idSet.idPairs, contains(TestIdPair('ISBN', '123')));
      expect(idSet.idPairs, contains(TestIdPair('UPC', '456')));
      expect(idSet.idPairs, contains(TestIdPair('EAN', '789')));
    });

    test('handles multiple duplicates', () {
      final pairs = [
        TestIdPair('ISBN', '123'),
        TestIdPair('ISBN', '123'),
        TestIdPair('ISBN', '123'),
        TestIdPair('UPC', '456'),
      ];
      final idSet = IdPairSet(pairs);

      expect(idSet.idPairs.length, 2);
    });

    test('preserves order of first occurrences', () {
      final pairs = [
        TestIdPair('isbn', '123'),
        TestIdPair('upc', '456'),
        TestIdPair('isbn', '123'), // duplicate
        TestIdPair('ean', '789'),
        TestIdPair('upc', '456'), // duplicate
      ];
      final idSet = IdPairSet(pairs);

      expect(idSet.idPairs.length, 3);
      expect(idSet.idPairs[0], TestIdPair('isbn', '123'));
      expect(idSet.idPairs[1], TestIdPair('upc', '456'));
      expect(idSet.idPairs[2], TestIdPair('ean', '789'));
    });

    test(
      'treats pairs with same idType and idCode as duplicates even if other properties differ',
      () {
        // Since TestIdPair only has idType and idCode, but in theory if there were more props
        // But for now, it's the same
        final pairs = [TestIdPair('ISBN', '123'), TestIdPair('ISBN', '123')];
        final idSet = IdPairSet(pairs);

        expect(idSet.idPairs.length, 1);
      },
    );
    test('handles large lists with many duplicates', () {
      final pairs = List.generate(
        1000,
        (i) => TestIdPair('TYPE', 'CODE${i % 10}'),
      );
      final idSet = IdPairSet(pairs);

      expect(idSet.idPairs.length, 1); // all have same idType 'TYPE'
    });

    test(
      'handles null idType and idCode if possible, but since String, empty strings',
      () {
        final pairs = [
          TestIdPair('', ''),
          TestIdPair('', ''),
          TestIdPair('A', 'B'),
        ];
        final idSet = IdPairSet(pairs);

        expect(idSet.idPairs.length, 2);
      },
    );

    test('addPair adds a new pair to the set', () {
      final pairs = [TestIdPair('ISBN', '123')];
      final idSet = IdPairSet(pairs);
      final newPair = TestIdPair('UPC', '456');
      final updatedSet = idSet.addPair(newPair);

      expect(updatedSet.idPairs.length, 2);
      expect(updatedSet.idPairs, contains(TestIdPair('ISBN', '123')));
      expect(updatedSet.idPairs, contains(TestIdPair('UPC', '456')));
    });

    test('addPair does not add duplicate pairs', () {
      final pairs = [TestIdPair('ISBN', '123')];
      final idSet = IdPairSet(pairs);
      final duplicatePair = TestIdPair('ISBN', '123');
      final updatedSet = idSet.addPair(duplicatePair);

      expect(updatedSet.idPairs.length, 1);
      expect(updatedSet.idPairs, contains(TestIdPair('ISBN', '123')));
    });

    test('addPair replaces pair with existing idType', () {
      final pairs = [TestIdPair('ISBN', '123')];
      final idSet = IdPairSet(pairs);
      final sameTypePair = TestIdPair('ISBN', '789');
      final updatedSet = idSet.addPair(sameTypePair);

      expect(updatedSet.idPairs.length, 1);
      expect(updatedSet.idPairs, contains(TestIdPair('ISBN', '789')));
      expect(updatedSet.idPairs, isNot(contains(TestIdPair('ISBN', '123'))));
    });

    test('removePair removes an existing pair from the set', () {
      final pairs = [TestIdPair('ISBN', '123'), TestIdPair('UPC', '456')];
      final idSet = IdPairSet(pairs);
      final pairToRemove = TestIdPair('ISBN', '123');
      final updatedSet = idSet.removePair(pairToRemove);

      expect(updatedSet.idPairs.length, 1);
      expect(updatedSet.idPairs, contains(TestIdPair('UPC', '456')));
      expect(updatedSet.idPairs, isNot(contains(TestIdPair('ISBN', '123'))));
    });

    test('removePair does nothing if pair does not exist', () {
      final pairs = [TestIdPair('ISBN', '123')];
      final idSet = IdPairSet(pairs);
      final nonExistentPair = TestIdPair('UPC', '456');
      final updatedSet = idSet.removePair(nonExistentPair);

      expect(updatedSet.idPairs.length, 1);
      expect(updatedSet.idPairs, contains(TestIdPair('ISBN', '123')));
    });

    test('getByType returns pair with matching idType', () {
      final pairs = [
        TestIdPair('ISBN', '123'),
        TestIdPair('UPC', '456'),
        TestIdPair('ISBN', '789'),
      ];
      final idSet = IdPairSet(pairs);
      final isbnSet = idSet.getByType('ISBN');

      expect(isbnSet.idPairs.length, 1);
      expect(isbnSet.idPairs, contains(TestIdPair('ISBN', '789')));
      expect(isbnSet.idPairs, isNot(contains(TestIdPair('ISBN', '123'))));
      expect(isbnSet.idPairs, isNot(contains(TestIdPair('UPC', '456'))));
    });

    test('getByType returns empty set if no matches', () {
      final pairs = [TestIdPair('ISBN', '123')];
      final idSet = IdPairSet(pairs);
      final upcSet = idSet.getByType('UPC');

      expect(upcSet.idPairs.length, 0);
    });

    test('constructor keeps first pair when keepLast is false', () {
      final pairs = [
        TestIdPair('ISBN', '123'),
        TestIdPair('UPC', '456'),
        TestIdPair('ISBN', '789'),
      ];
      final idSet = IdPairSet(pairs, keepLast: false);

      expect(idSet.idPairs.length, 2);
      expect(idSet.idPairs, contains(TestIdPair('ISBN', '123')));
      expect(idSet.idPairs, isNot(contains(TestIdPair('ISBN', '789'))));
      expect(idSet.idPairs, contains(TestIdPair('UPC', '456')));
    });

    test('addPair does not replace when keepLast is false', () {
      final pairs = [TestIdPair('isbn', '123')];
      final idSet = IdPairSet(pairs, keepLast: false);
      final sameTypePair = TestIdPair('isbn', '789');
      final updatedSet = idSet.addPair(sameTypePair);

      expect(updatedSet.idPairs.length, 1);
      expect(updatedSet.idPairs, contains(TestIdPair('isbn', '123')));
      expect(updatedSet.idPairs, isNot(contains(TestIdPair('isbn', '789'))));
    });

    test('toString returns empty string for empty set', () {
      final idSet = IdPairSet(<IdPair>[]);
      expect(idSet.toString(), '');
    });

    test('toString returns formatted string for single pair', () {
      final pairs = [TestIdPair('isbn', '1234567890')];
      final idSet = IdPairSet(pairs);
      expect(idSet.toString(), 'isbn:1234567890');
    });

    test('toString returns formatted string sorted by idType name', () {
      final pairs = [
        TestIdPair('upc', '456'),
        TestIdPair('isbn', '123'),
        TestIdPair('ean', '789'),
      ];
      final idSet = IdPairSet(pairs);
      expect(idSet.toString(), 'ean:789|isbn:123|upc:456');
    });

    test('toString handles duplicates correctly', () {
      final pairs = [
        TestIdPair('isbn', '123'),
        TestIdPair('isbn', '456'), // duplicate type, keep last
      ];
      final idSet = IdPairSet(pairs);
      expect(idSet.toString(), 'isbn:456');
    });
  });
}
