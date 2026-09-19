import 'package:id_pair_set/id_pair_set.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

/// An enum-keyed pair, proving [IdPair.idType] keeps its static type.
enum Namespace { isbn, upc, bally }

/// A pair whose id types are enum values rather than strings.
class KeyedId extends IdPair<Namespace> {
  /// Creates an identifier in the namespace [idType] holding [idCode].
  const KeyedId(this.idType, this.idCode);

  @override
  final Namespace idType;

  @override
  final String idCode;

  @override
  KeyedId copyWith({Namespace? idType, String? idCode}) =>
      KeyedId(idType ?? this.idType, idCode ?? this.idCode);
}

void main() {
  group('Given an IdPair', () {
    group('When two pairs share id type and code', () {
      test('Then they are equal and share a hash code', () {
        const one = SimpleIdPair('isbn', '978-3-16-148410-0');
        const other = SimpleIdPair('isbn', '978-3-16-148410-0');

        one.should.be(other);
        one.hashCode.should.be(other.hashCode);
      });
    });

    group('When two pairs differ in code or type', () {
      test('Then they are not equal', () {
        const one = SimpleIdPair('isbn', '978-3-16-148410-0');
        const otherCode = SimpleIdPair('isbn', '978-1-23-456789-0');
        const otherType = SimpleIdPair('ean', '978-3-16-148410-0');

        one.should.not.be(otherCode);
        one.should.not.be(otherType);
      });
    });

    group('When the code carries a value', () {
      test('Then the pair is valid and names itself by type and code', () {
        const pair = SimpleIdPair('isbn', '978-3-16-148410-0');

        pair.isValid.should.be(true);
        pair.displayName.should.be('isbn: 978-3-16-148410-0');
        pair.props.should.haveCount(2);
        pair.props.should.contain('isbn');
      });
    });

    group('When the code is blank', () {
      test('Then the pair is not valid', () {
        const pair = SimpleIdPair('isbn', '   ');

        pair.isValid.should.be(false);
      });
    });

    group('When copying with one field replaced', () {
      test('Then the other field is kept', () {
        const pair = SimpleIdPair('isbn', '978-3-16-148410-0');

        pair.copyWith(idCode: '123').idCode.should.be('123');
        pair.copyWith(idCode: '123').idType.should.be('isbn');
        pair.copyWith(idType: 'ean').idType.should.be('ean');
        pair.copyWith(idType: 'ean').idCode.should.be('978-3-16-148410-0');
      });
    });

    group('When the id type is an enum', () {
      test('Then it stays that enum — no cast, no dynamic', () {
        const pair = KeyedId(Namespace.bally, 'A-16486-GLM');

        pair.idType.should.be(Namespace.bally);
        pair.copyWith(idCode: 'A-1').idType.should.be(Namespace.bally);
      });
    });
  });
}
