import 'package:id_pair_set/id_pair_set.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

/// An enum-keyed pair, used to prove the JSON codec works off plain strings.
enum Namespace { isbn, bally }

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

const isbn = SimpleIdPair('isbn', '978-3-16-148410-0');
const upc = SimpleIdPair('upc', '123456789012');
const ballyOne = SimpleIdPair('bally', 'A-16486-GLM');
const ballyTwo = SimpleIdPair('bally', 'A-99999');

void main() {
  group('Given an IdPairSet built from distinct types', () {
    test('Then it holds one pair per type, in first-seen order', () {
      final set = IdPairSet([isbn, upc, ballyOne]);

      set.length.should.be(3);
      set.isNotEmpty.should.be(true);
      set.isEmpty.should.be(false);
      set.pairs.should.haveCount(3);
      set.pairs[0].should.be(isbn);
      set.idTypes.should.contain('bally');
      set.hasDuplicates.should.be(false);
      set.duplicates.should.beEmpty();
      set.policy.should.be(DuplicatePolicy.lastWins);
    });
  });

  group('Given two pairs sharing an id type', () {
    group('When the policy is lastWins', () {
      test('Then the later pair is kept and the earlier is reported', () {
        final set = IdPairSet([ballyOne, ballyTwo]);

        set.length.should.be(1);
        set['bally'].should.be(ballyTwo);
        set.hasDuplicates.should.be(true);
        set.duplicates.should.haveCount(1);
        set.duplicates.should.contain(ballyOne);
      });
    });

    group('When the policy is firstWins', () {
      test('Then the earlier pair is kept and the later is reported', () {
        final set = IdPairSet([
          ballyOne,
          ballyTwo,
        ], policy: DuplicatePolicy.firstWins);

        set['bally'].should.be(ballyOne);
        set.duplicates.should.contain(ballyTwo);
        set.policy.should.be(DuplicatePolicy.firstWins);
      });
    });
  });

  group('Given two sets holding the same pairs', () {
    group('When they were built in a different order', () {
      test('Then they are equal and share a hash code', () {
        final forward = IdPairSet([isbn, upc, ballyOne]);
        final backward = IdPairSet([ballyOne, upc, isbn]);

        forward.should.be(backward);
        forward.hashCode.should.be(backward.hashCode);
      });
    });

    group('When a pair no-op add is applied', () {
      test('Then the set is unchanged, not merely reordered', () {
        final set = IdPairSet([isbn, upc]);

        set.add(isbn).should.be(set);
        set.addAll([isbn, upc]).should.be(set);
      });
    });
  });

  group('Given a set with a type already registered', () {
    group('When adding a pair with a new code for that type', () {
      test('Then the new code replaces the old one', () {
        final set = IdPairSet([ballyOne]).add(ballyTwo);

        set.length.should.be(1);
        set['bally'].should.be(ballyTwo);
        set.containsCode('A-16486-GLM').should.be(false);
      });
    });
  });

  group('Given a set holding two types', () {
    group('When removing by an exactly matching pair', () {
      test('Then only that pair goes', () {
        final set = IdPairSet([isbn, upc]);

        set.remove(isbn).containsType('isbn').should.be(false);
        set.remove(isbn).containsType('upc').should.be(true);
        set.remove(isbn).length.should.be(1);
      });
    });

    group('When removing by a stale code for a held type', () {
      test('Then the set is unchanged', () {
        final set = IdPairSet([isbn, upc]);

        set.remove(const SimpleIdPair('isbn', 'stale')).should.be(set);
      });
    });

    group('When removing by type', () {
      test('Then whatever code that type held goes', () {
        final set = IdPairSet([isbn, ballyOne]);

        set.removeType('bally').containsType('bally').should.be(false);
        set.removeType('bally').length.should.be(1);
        set.removeType('absent').should.be(set);
      });
    });
  });

  group('Given a set of two types', () {
    group('When looking pairs up', () {
      test('Then a held type answers and an absent one is null', () {
        final set = IdPairSet([isbn, upc]);

        set['isbn'].should.be(isbn);
        set['ean'].should.beNull();
        set.contains(isbn).should.be(true);
        set.contains(const SimpleIdPair('isbn', 'other')).should.be(false);
        set.containsCode('123456789012').should.be(true);
        set.containsCode('nope').should.be(false);
      });
    });
  });

  group('Given a set of string-keyed pairs', () {
    group('When it round-trips through JSON', () {
      test('Then it encodes as a type-to-code object and reads back equal', () {
        final set = IdPairSet([isbn, ballyOne]);
        final json = set.toJson();
        final code = json['isbn'] as String?;

        json.should.containKey('isbn');
        code.should.be('978-3-16-148410-0');
        IdPairSet.fromPlainJson(json).should.be(set);
        IdPairSet.fromPlainJson(json).hashCode.should.be(set.hashCode);
      });
    });

    group('When a stored value is null', () {
      test('Then that entry is skipped rather than stored as a code', () {
        final decoded = IdPairSet.fromPlainJson({'isbn': '978', 'ean': null});

        decoded.length.should.be(1);
        decoded['ean'].should.beNull();
      });
    });
  });

  group('Given a set whose id types are enums', () {
    group('When it round-trips through JSON with a builder', () {
      test('Then the builder maps stored type names back onto the enum', () {
        final set = IdPairSet([
          const KeyedId(Namespace.bally, 'A-16486-GLM'),
          const KeyedId(Namespace.isbn, '978-3-16-148410-0'),
        ]);
        final decoded = IdPairSet.fromJson(
          set.toJson(),
          pairFromJson: (idType, idCode) =>
              KeyedId(Namespace.values.byName(idType), idCode),
        );

        set.toJson().should.containKey('bally');
        decoded.should.be(set);
        decoded[Namespace.bally]!.idCode.should.be('A-16486-GLM');
      });
    });
  });

  group('Given a set of unordered types', () {
    group('When rendering it for a log', () {
      test('Then the rendering is sorted and carries type and code', () {
        final set = IdPairSet([upc, isbn]);

        set.toString().should.be('isbn:978-3-16-148410-0|upc:123456789012');
        IdPairSet<SimpleIdPair>([]).toString().should.be('');
      });
    });
  });
}
