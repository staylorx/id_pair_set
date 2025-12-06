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
    return TestIdPair(
      (idType as String?) ?? this.idType,
      idCode ?? this.idCode,
    );
  }
}

void main() {
  group('IdPair', () {
    test('equality works correctly', () {
      final pair1 = TestIdPair('type1', 'code1');
      final pair2 = TestIdPair('type1', 'code1');
      final pair3 = TestIdPair('type2', 'code1');

      expect(pair1, equals(pair2));
      expect(pair1, isNot(equals(pair3)));
    });

    test('hashCode is consistent with equality', () {
      final pair1 = TestIdPair('type1', 'code1');
      final pair2 = TestIdPair('type1', 'code1');

      expect(pair1.hashCode, equals(pair2.hashCode));
    });

    test('copyWith creates new instance with updated values', () {
      final original = TestIdPair('type1', 'code1');
      final copied = original.copyWith(idType: 'type2', idCode: 'code2');

      expect(copied.idType, 'type2');
      expect(copied.idCode, 'code2');
      expect(original.idType, 'type1'); // original unchanged
    });

    test('copyWith with null values keeps original', () {
      final original = TestIdPair('type1', 'code1');
      final copied = original.copyWith();

      expect(copied.idType, 'type1');
      expect(copied.idCode, 'code1');
    });

    test('isValid returns true for non-empty idCode', () {
      final valid = TestIdPair('type', 'code');
      final invalid = TestIdPair('type', '');

      expect(valid.isValid, isTrue);
      expect(invalid.isValid, isFalse);
    });

    test('displayName formats correctly', () {
      final pair = TestIdPair('ISBN', '1234567890');
      expect(pair.displayName, 'ISBN: 1234567890');
    });
  });
}
