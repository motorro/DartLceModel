import 'dart:io';

import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_lce.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';
import 'package:dartlcemodel/src/model/cache_then_net_lce_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<ServiceSet<int, String>>(),
  MockSpec<CacheService<int, String>>(),
  MockSpec<NetService<int, String>>()
])
import 'cache_then_net_lce_model_test.mocks.dart';

void main() {
  final params = 'params';
  final validEntity = Entity.create(1, AlwaysValid.instance);
  final invalidEntity = Entity.create(1, NeverValid.instance);

  late MockCacheService cache;
  late MockNetService net;

  setUp(() {
    cache = MockCacheService();
    when(cache.save(any, any)).thenAnswer((_) => Future.value());

    net = MockNetService();
    when(net.get(any)).thenAnswer((_) => Future.value(validEntity));
  });

  LceModel<int, String> createModel({ Stream<LceState<int>>? initial }) {
    final serviceSet = MockServiceSet();
    when(serviceSet.cache).thenReturn(cache);
    when(serviceSet.net).thenReturn(net);

    return CacheThenNetLceModel(params, serviceSet, startWith: initial ?? Stream.empty());
  }

  group('CacheThenNetLceModel', () {
    test('will load cached data and will not load net if valid', () async {
      when(cache.getData(any)).thenAnswer((_) => Stream.value(validEntity));
      final model = createModel();

      await expectLater(
          model.state,
          emitsInOrder([LceState.content(validEntity.data, true)])
      );

      verify(cache.getData(params)).called(equals(1));
      verifyNever(net.get(params));
    });

    test('will start with passed initial emission', () async {
      when(cache.getData(any)).thenAnswer((_) => Stream.value(validEntity));
      final model = createModel(initial: Stream.value(LceState<int>.loading(null, false)));

      await expectLater(
          model.state,
          emitsInOrder([
            LceState<int>.loading(null, false),
            LceState.content(validEntity.data, true)
          ])
      );
    });

    test('will load cached data and load net if no cached data, saving to cache', () async {
      when(cache.getData(any)).thenAnswer((_) => Stream.value(null));
      final model = createModel();

      await expectLater(
          model.state,
          emitsInOrder([
            LceState<int>.loading(null, false)
          ])
      );

      verify(cache.getData(params)).called(equals(1));
      verify(net.get(params)).called(equals(1));
      verify(cache.save(params, validEntity)).called(equals(1));
    });

    test('will load cached data and load net if outdated, saving to cache', () async {
      when(cache.getData(any)).thenAnswer((_) => Stream.value(invalidEntity));
      final model = createModel();

      await expectLater(
          model.state,
          emitsInOrder([
            LceState<int>.loading(invalidEntity.data, false, LoadingType.refreshing)
          ])
      );

      verify(cache.getData(params)).called(equals(1));
      verify(net.get(params)).called(equals(1));
      verify(cache.save(params, validEntity)).called(equals(1));
    });

    test('will update when cache updates', () async {
      when(cache.getData(any)).thenAnswer((_) => Stream.fromIterable([null, validEntity]));
      final model = createModel();

      await expectLater(
          model.state,
          emitsInOrder([
            LceState<int>.loading(null, false),
            LceState<int>.content(validEntity.data, true),
          ])
      );
    });

    test('will invalidate cache on refresh', () async {
      when(cache.invalidate(any)).thenAnswer((_) => Future.value());
      final model = createModel();

      await expectLater(
          model.refresh(),
          completes
      );

      verify(cache.invalidate(params)).called(equals(1));
    });

    test('will report network error', () async {
      final error = StdinException("error");
      when(cache.getData(any)).thenAnswer((_) => Stream.value(invalidEntity));
      when(net.get(any)).thenAnswer((_) => Future.error(error));
      final model = createModel();

      await expectLater(
          model.state,
          emitsInOrder([
            LceState.loading(invalidEntity.data, false, LoadingType.refreshing),
            LceState.error(invalidEntity.data, false, error)
          ])
      );

      verify(cache.getData(params)).called(equals(1));
      verify(net.get(params)).called(equals(1));
      verifyNever(cache.save(any, any));
    });
  });
}


