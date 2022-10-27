import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_utils.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../utils.dart';
@GenerateNiceMocks([MockSpec<Clock>()])
import 'entity_test.mocks.dart';

void main() {
  group('Simple', () {
    test('serializes and deserializes', () {
      var v = Simple(true);
      var s = v.serialize();
      expect(
          v,
          equals(Simple.deserializer.deserialize(s))
      );
      expect(
          v.isValid(),
          isTrue
      );

      v = Simple(false);
      s = v.serialize();
      expect(
          v,
          equals(Simple.deserializer.deserialize(s))
      );
      expect(
          v.isValid(),
          isFalse
      );
    });
  });

  group('Lifespan', () {
    late Clock clock;
    late EntityValidatorDeserializer deserializer;

    setUp(() {
      clock = MockClock();
      deserializer = Lifespan.deserializer(clock);
    });

    test('serializes and deserializes', () {
      when(clock.getMillis()).thenReturn(5);

      var v = Lifespan.dynamic(5, clock);
      var s = v.serialize();
      expect(
          v,
          equals(deserializer.deserialize(s))
      );
    });

    test('will not deserialize unknown string', () {
      when(clock.getMillis()).thenReturn(5);

      final s = 'Unknown';
      expect(
          deserializer.deserialize(s),
          isNull
      );
    });

    test('should equal to another up-to-date lifespan', () {
      when(clock.getMillis()).thenReturnOneByOne([5, 10]);

      final entity1 = Lifespan.dynamic(15, clock);
      final entity2 = Lifespan.dynamic(25, clock);
      expect(
          entity1,
          equals(entity2)
      );
    });

    test('should not be equal to another lifespan', () {
      when(clock.getMillis()).thenReturnOneByOne([5, 10, 30]);

      final entity1 = Lifespan.dynamic(15, clock);
      final entity2 = Lifespan.dynamic(25, clock);

      // Tick the clock - see clock mock above
      expect(
          entity1.isValid(),
          isFalse
      );
      expect(
          entity2.isValid(),
          isTrue
      );

      expect(
          entity1,
          isNot(entity2)
      );
    });

    test('has equal hash-code when both valid', () {
      when(clock.getMillis()).thenReturnOneByOne([5, 10]);

      final entity1 = Lifespan.dynamic(15, clock);
      final entity2 = Lifespan.dynamic(25, clock);

      expect(
          entity1.hashCode,
          equals(entity2.hashCode)
      );
    });

    test('has not equal hash-code when validity differs', () {
      when(clock.getMillis()).thenReturnOneByOne([5, 10, 30]);

      final entity1 = Lifespan.dynamic(15, clock);
      final entity2 = Lifespan.dynamic(25, clock);

      // Tick the clock - see clock mock above
      expect(
          entity1.isValid(),
          isFalse
      );
      expect(
          entity2.isValid(),
          isTrue
      );

      expect(
          entity1.hashCode,
          isNot(entity2.hashCode)
      );
    });

    test('dynamic expires', () {
      when(clock.getMillis()).thenReturnOneByOne([5, 10, 30]);

      final entity1 = Lifespan.dynamic(5, clock);

      expect(
          entity1.isValid(),
          isTrue
      );
      expect(
          entity1.isValid(),
          isFalse
      );
    });

    test('snapshot will not expire', () {
      when(clock.getMillis()).thenReturnOneByOne([5, 10, 30]);

      final entity1 = Lifespan.snapshot(5, clock);

      expect(
          entity1.isValid(),
          isTrue
      );
      expect(
          entity1.isValid(),
          isTrue
      );
    });

    test('deserializes snapshot', () {
      when(clock.getMillis()).thenReturnOneByOne([5, 10, 15]);

      final entity1 = Lifespan.dynamic(5, clock);

      final serialized = entity1.serialize();
      final deserialized = Lifespan.deserializer(clock).deserializeSnapshot(serialized);

      expect(
          deserialized!.isValid(),
          isTrue
      );
    });

    test('deserialized snapshot creates lifspan', () {
      when(clock.getMillis()).thenReturnOneByOne([5, 10, 15]);

      final entity1 = Lifespan.dynamic(5, clock);
      expect(
          entity1.isValid(),
          isTrue
      );

      final serialized = entity1.serialize();
      final deserialized = Lifespan.deserializer(clock).deserializeSnapshot(serialized);
      expect(
          deserialized!.isValid(),
          isFalse
      );
    });
  });

  group('AlwaysValid', () {
    test('serializes and deserializes', () {
      var v = AlwaysValid.instance;
      var s = v.serialize();
      expect(
          v,
          equals(AlwaysValid.deserializer.deserialize(s))
      );
    });

    test('will not deserialize unknown string', () {
      final s = 'Unknown';
      expect(
          AlwaysValid.deserializer.deserialize(s),
          isNull
      );
    });
  });

  group('NeverValid', () {
    test('serializes and deserializes', () {
      var v = NeverValid.instance;
      var s = v.serialize();
      expect(
          v,
          equals(NeverValid.deserializer.deserialize(s))
      );
    });

    test('will not deserialize unknown string', () {
      final s = 'Unknown';
      expect(
          NeverValid.deserializer.deserialize(s),
          isNull
      );
    });
  });
}

