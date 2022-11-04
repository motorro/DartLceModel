import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<SyncCacheDelegate>(),
  MockSpec<AsyncCacheDelegate>()
])
import 'cacheFriendDelegate_test.mocks.dart';

void main() {
  final CacheFriend params = CacheFriend.create('params1');
  final Entity<String> entity = Entity.create('data', AlwaysValid.instance);

  group('Sync friend delegate', () {
    late SyncCacheDelegate<DataWithCacheKey<String>, CacheFriend> cacheDelegate;
    late SyncCacheDelegate<String, CacheFriend> friendDelegate;

    setUp(() {
      cacheDelegate = MockSyncCacheDelegate<DataWithCacheKey<String>, CacheFriend>();
      friendDelegate = SyncCacheFriendDelegate(cacheDelegate);
    });

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

  group('SyncCacheFriendExtension', (){
    test('creates friend wrapper', () {
      final delegate = MockSyncCacheDelegate<String, CacheFriend>();
      final SyncCacheDelegate<String, String> wrapper = delegate.makeFriendParams((params) => params);
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

  group('Async friend delegate', () {
    late AsyncCacheDelegate<DataWithCacheKey<String>, CacheFriend> cacheDelegate;
    late AsyncCacheDelegate<String, CacheFriend> friendDelegate;

    setUp(() {
      cacheDelegate = MockAsyncCacheDelegate<DataWithCacheKey<String>, CacheFriend>();
      friendDelegate = AsyncCacheFriendDelegate(cacheDelegate);
    });

    test('saves data with cache key', () async {
      await friendDelegate.save(params, entity);
      verify(cacheDelegate.save(params, entity.map((_) => DataWithCacheKey('data', 'params1'))));
    });

    test('if key matches returns data', () {
      when(cacheDelegate.get(params)).thenAnswer( (_) async {
        return entity.map((_) => DataWithCacheKey('data', 'params1'));
      });
      expect(friendDelegate.get(params), completion(equals(entity)));
    });

    test('returns null if delegate returns null', () {
      expect(friendDelegate.get(params), completion(isNull));
    });

    test('returns null if params don\'t match', () {
      when(cacheDelegate.get(params)).thenAnswer( (_) async {
        entity.map((_) => DataWithCacheKey('data', 'params2'));
      });
      expect(friendDelegate.get(params), completion(isNull));
    });
  });

  group('AsyncCacheFriendExtension', (){
    test('creates friend wrapper', () async {
      final delegate = MockAsyncCacheDelegate<String, CacheFriend>();
      final AsyncCacheDelegate<String, String> wrapper = delegate.makeFriendParams((params) => params);
      final paramsMatcher = predicate<CacheFriend>((friend) => 'params' == friend.cacheKey, 'equals "params"');

      await wrapper.get('params');
      verify(delegate.get(argThat(paramsMatcher)));

      await wrapper.invalidate('params');
      verify(delegate.invalidate(argThat(paramsMatcher)));

      await wrapper.invalidateAll();
      verify(delegate.invalidateAll());

      await wrapper.delete('params');
      verify(delegate.delete(argThat(paramsMatcher)));
    });
  });
}

