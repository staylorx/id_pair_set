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

      expect(() => registry.register(set1), returnsNormally);
      expect(() => registry.register(set2), returnsNormally);

      expect(registry.isRegistered('isbn', '123'), isTrue);
      expect(registry.isRegistered('isbn', '789'), isTrue);
      expect(registry.isRegistered('local', 'abc'), isTrue);
      expect(registry.isRegistered('upc', '456'), isTrue);
    });

    test(
      'should throw DuplicateIdException for duplicate unique identifiers',
      () {
        final set1 = IdPairSet([TestId('isbn', '123')]);
        final set2 = IdPairSet([TestId('isbn', '123')]); // duplicate

        registry.register(set1);
        expect(
          () => registry.register(set2),
          throwsA(isA<DuplicateIdException>()),
        );
      },
    );

    test('should unregister identifiers', () {
      final set = IdPairSet([TestId('isbn', '123'), TestId('local', 'abc')]);

      registry.register(set);
      expect(registry.isRegistered('isbn', '123'), isTrue);
      expect(registry.isRegistered('local', 'abc'), isTrue);

      registry.unregister(set);
      expect(registry.isRegistered('isbn', '123'), isFalse);
      expect(registry.isRegistered('local', 'abc'), isFalse);
    });

    test('should return registered codes for type', () {
      final set1 = IdPairSet([TestId('isbn', '123')]);
      final set2 = IdPairSet([TestId('isbn', '456')]);

      registry.register(set1);
      registry.register(set2);

      expect(registry.getRegisteredCodes('isbn'), containsAll(['123', '456']));
      expect(registry.getRegisteredCodes('local'), isEmpty);
    });

    test('should clear all registrations', () {
      final set = IdPairSet([TestId('isbn', '123')]);
      registry.register(set);
      expect(registry.isRegistered('isbn', '123'), isTrue);

      registry.clear();
      expect(registry.isRegistered('isbn', '123'), isFalse);
    });
  });
}
