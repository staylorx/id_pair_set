import 'package:test/test.dart';
import 'package:id_pair_set/id_pair_set.dart';

class TestId extends IdPair {
  @override
  final String idType;
  @override
  final String idCode;

  TestId(this.idType, this.idCode);

  @override
  List<Object?> get props => [idType, idCode];

  @override
  bool get isValid => idCode.isNotEmpty;

  @override
  String get displayName => '$idType: $idCode';

  @override
  IdPair copyWith({dynamic idType, String? idCode}) {
    return TestId(idType as String? ?? this.idType, idCode ?? this.idCode);
  }
}

void main() {
  group('IdRegistry', () {
    late IdRegistry registry;

    setUp(() {
      registry = IdRegistry();
    });

    test('should register unique identifiers successfully', () {
      final set1 = IdPairSet([TestId('isbn', '123'), TestId('upc', '456')]);

      final set2 = IdPairSet([TestId('isbn', '789'), TestId('local', 'abc')]);

      expect(() => registry.register(idPairSet: set1), returnsNormally);
      expect(() => registry.register(idPairSet: set2), returnsNormally);

      expect(registry.isRegistered(idType: 'isbn', idCode: '123'), isTrue);
      expect(registry.isRegistered(idType: 'isbn', idCode: '789'), isTrue);
      expect(registry.isRegistered(idType: 'local', idCode: 'abc'), isTrue);
      expect(registry.isRegistered(idType: 'upc', idCode: '456'), isTrue);
    });

    test(
      'should throw DuplicateIdException for duplicate unique identifiers',
      () {
        final set1 = IdPairSet([TestId('isbn', '123')]);
        final set2 = IdPairSet([TestId('isbn', '123')]); // duplicate

        registry.register(idPairSet: set1);
        expect(
          () => registry.register(idPairSet: set2),
          throwsA(isA<DuplicateIdException>()),
        );
      },
    );

    test('should unregister identifiers', () {
      final set = IdPairSet([TestId('isbn', '123'), TestId('local', 'abc')]);

      registry.register(idPairSet: set);
      expect(registry.isRegistered(idType: 'isbn', idCode: '123'), isTrue);
      expect(registry.isRegistered(idType: 'local', idCode: 'abc'), isTrue);

      registry.unregister(idPairSet: set);
      expect(registry.isRegistered(idType: 'isbn', idCode: '123'), isFalse);
      expect(registry.isRegistered(idType: 'local', idCode: 'abc'), isFalse);
    });

    test('should return registered codes for type', () {
      final set1 = IdPairSet([TestId('isbn', '123')]);
      final set2 = IdPairSet([TestId('isbn', '456')]);

      registry.register(idPairSet: set1);
      registry.register(idPairSet: set2);

      expect(
        registry.getRegisteredCodes(idType: 'isbn'),
        containsAll(['123', '456']),
      );
      expect(registry.getRegisteredCodes(idType: 'local'), isEmpty);
    });

    test('should clear all registrations', () {
      final set = IdPairSet([TestId('isbn', '123')]);
      registry.register(idPairSet: set);
      expect(registry.isRegistered(idType: 'isbn', idCode: '123'), isTrue);

      registry.clear();
      expect(registry.isRegistered(idType: 'isbn', idCode: '123'), isFalse);
    });

    test('should set and generate autoincrement IDs', () {
      registry.setGenerationType(
        idType: 'local',
        type: IdGenerationType.autoincrement,
      );

      expect(registry.generateId(idType: 'local'), '0');
      expect(registry.generateId(idType: 'local'), '1');
      expect(registry.generateId(idType: 'local'), '2');
    });

    test('should generate UUID IDs', () {
      registry.setGenerationType(idType: 'local', type: IdGenerationType.uuid);

      final id1 = registry.generateId(idType: 'local');
      final id2 = registry.generateId(idType: 'local');

      // UUID v4 format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx where y is 8,9,a,b
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(uuidRegex.hasMatch(id1), isTrue);
      expect(uuidRegex.hasMatch(id2), isTrue);
      expect(id1, isNot(equals(id2)));
    });
  });
}
