import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_utils.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../utils.dart';
@GenerateNiceMocks([
  MockSpec<Clock>()
])
import 'entityValidatorFactory_test.mocks.dart';

void main() {
  late Clock clock;
  late EntityValidatorFactory factory;

  setUp(() {
    clock = MockClock();
    when(clock.getMillis()).thenReturnOneByOne([5, 10, 15]);
    factory = EntityValidatorFactory.lifespan(5, clock);
  });

  group('Lifespan factory', () {
    test('deserializes Lifespan', () {
      final lifespan = Lifespan.dynamic(5, clock);
      final fromFactory = factory.create(lifespan.serialize());

      expect(
        fromFactory,
        isA<Lifespan>()
      );
      expect(
        fromFactory.isValid(),
        isTrue
      );
      expect(
        fromFactory.isValid(),
        isFalse
      );
    });

    test('creates Lifespan', () {
      final fromFactory = factory.create();
      expect(
          fromFactory.isValid(),
          isTrue
      );
      expect(
          fromFactory.isValid(),
          isFalse
      );
    });

    test('deserializes Lifespan snapshot', () {
      final lifespan = Lifespan.dynamic(5, clock);
      final fromFactory = factory.createSnapshot(lifespan.serialize());

      expect(
        fromFactory,
        isA<Lifespan>()
      );
      expect(
        fromFactory.isValid(),
        isTrue
      );
      expect(
        fromFactory.isValid(),
        isTrue
      );
    });

    test('creates Lifespan snapshot', () {
      final fromFactory = factory.createSnapshot();
      expect(
          fromFactory.isValid(),
          isTrue
      );
      expect(
          fromFactory.isValid(),
          isTrue
      );
    });
  });
}