import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<CacheDelegate>()
])
import 'cacheFriendDelegate_test.mocks.dart';

void main() {
  final CacheFriend params = CacheFriend.create('params1');
  final Entity<String> entity = Entity.create('data', AlwaysValid.instance);

  late CacheDelegate<DataWithCacheKey<String>, CacheFriend> cacheDelegate;
  late CacheDelegate<String, CacheFriend> friendDelegate;

  setUp(() {
    cacheDelegate = MockCacheDelegate<DataWithCacheKey<String>, CacheFriend>();
    friendDelegate = CacheFriendDelegate(cacheDelegate);
  });

  group('Friend delegate', () {
    test('saves data with cache key', () {
      friendDelegate.save(params, entity);
      verify(cacheDelegate.save(params, entity.map((_) => DataWithCacheKey('data', 'params1'))));
    });

    test('if key matches returns data', () {
      when(cacheDelegate.get(params)).thenReturn(entity.map((_) => DataWithCacheKey('data', 'params1')));
      expect(friendDelegate.get(params), equals(entity));
    });

    test('returns null if delegate returns null', () {
      expect(friendDelegate.get(params), isNull);
    });

    test('returns null if params don\'t match', () {
      when(cacheDelegate.get(params)).thenReturn(entity.map((_) => DataWithCacheKey('data', 'params2')));
      expect(friendDelegate.get(params), isNull);
    });
  });

  group('CacheFriendExtension', (){
    test('creates friend wrapper', () {
      final delegate = MockCacheDelegate<String, CacheFriend>();
      final CacheDelegate<String, String> wrapper = delegate.makeFriendParams((params) => params);
      final paramsMatcher = predicate<CacheFriend>((friend) => 'params' == friend.cacheKey, 'equals "params"');

      wrapper.get('params');
      verify(delegate.get(argThat(paramsMatcher)));

      wrapper.invalidate('params');
      verify(delegate.invalidate(argThat(paramsMatcher)));

      wrapper.invalidateAll();
      verify(delegate.invalidateAll());

      wrapper.delete('params');
      verify(delegate.delete(argThat(paramsMatcher)));
    });
  });
}

