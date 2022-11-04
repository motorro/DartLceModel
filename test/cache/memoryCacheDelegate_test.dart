import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_utils.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../utils.dart';
@GenerateNiceMocks([
  MockSpec<Clock>()
])
import 'memoryCacheDelegate_test.mocks.dart';

void main() {
  late Clock clock;
  late SyncCacheDelegate<String, int> delegate;

  setUp(() {
    clock = MockClock();
    when(clock.getMillis()).thenReturnOneByOne([5, 10, 15]);
    delegate = MemoryCacheDelegate<String, int>.map();
  });

  group('MemoryCacheDelegate', () {
    test('returns data snapshots', () {
      final lifespan = Lifespan.dynamic(5, clock);
      final entity = Entity.create('data', lifespan);
      
      delegate.save(1, entity);

      final fromCache = delegate.get(1)!;

      expect(
        entity.isValid(),
        isFalse
      );
      expect(
        fromCache.isValid(),
        isTrue
      );
    });

    test('invalidates entries', () {
      final lifespan = Lifespan.dynamic(50, clock);
      final entity1 = Entity.create('data1', lifespan);
      final entity2 = Entity.create('data2', lifespan);

      delegate.save(1, entity1);
      delegate.save(2, entity2);

      expect(
          delegate.get(1)!.isValid(),
          isTrue
      );
      expect(
          delegate.get(2)!.isValid(),
          isTrue
      );

      delegate.invalidate(1);
      delegate.invalidate(3);

      expect(
          delegate.get(1)!.isValid(),
          isFalse
      );
      expect(
          delegate.get(2)!.isValid(),
          isTrue
      );
    });

    test('invalidates all entries', () {
      final lifespan = Lifespan.dynamic(50, clock);
      final entity1 = Entity.create('data1', lifespan);
      final entity2 = Entity.create('data2', lifespan);

      delegate.save(1, entity1);
      delegate.save(2, entity2);

      expect(
          delegate.get(1)!.isValid(),
          isTrue
      );
      expect(
          delegate.get(2)!.isValid(),
          isTrue
      );

      delegate.invalidateAll();

      expect(
          delegate.get(1)!.isValid(),
          isFalse
      );
      expect(
          delegate.get(2)!.isValid(),
          isFalse
      );
    });

    test('deletes entries', () {
      final lifespan = Lifespan.dynamic(50, clock);
      final entity1 = Entity.create('data1', lifespan);
      final entity2 = Entity.create('data2', lifespan);

      delegate.save(1, entity1);
      delegate.save(2, entity2);

      delegate.delete(1);

      expect(
          delegate.get(1),
          isNull
      );
      expect(
          delegate.get(2),
          isNotNull
      );
    });
  });
}