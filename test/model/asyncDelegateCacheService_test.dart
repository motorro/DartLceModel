import 'dart:io';

import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';
import 'package:dartlcemodel/src/model/service/asyncDelegateCacheService.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../utils.dart';
@GenerateNiceMocks([
  MockSpec<AsyncCacheDelegate<String, String>>()
])
import 'asyncDelegateCacheService_test.mocks.dart';


void main() {
  final params1 = "params1";
  final validEntity = Entity.create("data", AlwaysValid.instance);

  late MockAsyncCacheDelegate cacheDelegate;
  late CacheService<String, String> service;

  setUp(() {
    cacheDelegate = MockAsyncCacheDelegate();
    service = AsyncDelegateCacheService(cacheDelegate);
  });

  group('AsyncDelegateCacheService', () {
    test('gets nothing from delegate', () {
      expect(service.getData(params1).first, completion(isNull));
    });

    test('gets stored from delegate', () {
      when(cacheDelegate.get(any)).thenAnswer((_) => Future.value(validEntity));

      expect(service.getData(params1).first, completion(equals(validEntity)));
    });

    test('fails to get entity if delegate fails', () {
      final error = StdinException("error");
      when(cacheDelegate.get(any)).thenThrow(error);

      expect(
          service.getData(params1).first,
          throwsA(TypeMatcher<StdinException>())
      );
    });

    test('saves entity and updates from delegate', () {
      when(cacheDelegate.get(any)).thenReturnOneByOne([null, validEntity]);
      FakeAsync().run((async) {
        final List<Entity<String>?> values = [];
        service.getData(params1).listen((event) {
            values.add(event);
        });

        async.flushMicrotasks();
        expect(
          values,
          equals([null])
        );

        service.save(params1, validEntity);
        async.flushMicrotasks();

        expect(
            values,
            equals([null, validEntity])
        );
        verify(cacheDelegate.save(params1, validEntity));
        verify(cacheDelegate.get(params1)).called(equals(2));
      });
    });

    test('fails to save entity if delegate fails', () {
      final error = StdinException("error");
      when(cacheDelegate.get(any)).thenReturnOneByOne([null, validEntity]);
      when(cacheDelegate.save(any, any)).thenThrow(error);

      FakeAsync().run((async) {
        final List<Entity<String>?> values = [];
        service.getData(params1).listen((event) {
            values.add(event);
        });

        async.flushMicrotasks();
        expect(
          values,
          equals([null])
        );

        expect(
            service.save(params1, validEntity),
            throwsA(TypeMatcher<StdinException>())
        );
        async.flushMicrotasks();

        expect(
            values,
            equals([null])
        );
      });
    });

    test('refetches data from delegate', () {
      when(cacheDelegate.get(any)).thenReturnOneByOne([null, validEntity]);
      FakeAsync().run((async) {
        final List<Entity<String>?> values = [];
        service.getData(params1).listen((event) {
          values.add(event);
        });

        async.flushMicrotasks();
        expect(
            values,
            equals([null])
        );

        service.refetch(params1);
        async.flushMicrotasks();

        expect(
            values,
            equals([null, validEntity])
        );
        verify(cacheDelegate.get(params1)).called(equals(2));
      });
    });

    test('refetches all data from delegate', () {
      when(cacheDelegate.get(any)).thenReturnOneByOne([null, validEntity]);
      FakeAsync().run((async) {
        final List<Entity<String>?> values = [];
        service.getData(params1).listen((event) {
          values.add(event);
        });

        async.flushMicrotasks();
        expect(
            values,
            equals([null])
        );

        service.refetchAll();
        async.flushMicrotasks();

        expect(
            values,
            equals([null, validEntity])
        );
        verify(cacheDelegate.get(params1)).called(equals(2));
      });
    });

    test('invalidates cache and updates from delegate', () {
      when(cacheDelegate.get(any)).thenReturnOneByOne([null, null]);
      FakeAsync().run((async) {
        final List<Entity<String>?> values = [];
        service.getData(params1).listen((event) {
          values.add(event);
        });

        async.flushMicrotasks();
        expect(
            values,
            equals([null])
        );

        service.invalidate(params1);
        async.flushMicrotasks();

        expect(
            values,
            equals([null, null])
        );
        verify(cacheDelegate.invalidate(params1));
        verify(cacheDelegate.get(params1)).called(equals(2));
      });
    });

    test('fails to invalidate if delegate fails', () {
      final error = StdinException("error");
      when(cacheDelegate.get(any)).thenReturnOneByOne([null, validEntity]);
      when(cacheDelegate.invalidate(any)).thenThrow(error);

      FakeAsync().run((async) {
        final List<Entity<String>?> values = [];
        service.getData(params1).listen((event) {
          values.add(event);
        });

        async.flushMicrotasks();
        expect(
            values,
            equals([null])
        );

        expect(
            service.invalidate(params1),
            throwsA(TypeMatcher<StdinException>())
        );
        async.flushMicrotasks();

        expect(
            values,
            equals([null])
        );
      });
    });

    test('invalidates all cache and updates from delegate', () {
      when(cacheDelegate.get(any)).thenReturnOneByOne([null, null]);
      FakeAsync().run((async) {
        final List<Entity<String>?> values = [];
        service.getData(params1).listen((event) {
          values.add(event);
        });

        async.flushMicrotasks();
        expect(
            values,
            equals([null])
        );

        service.invalidateAll();
        async.flushMicrotasks();

        expect(
            values,
            equals([null, null])
        );
        verify(cacheDelegate.invalidateAll());
        verify(cacheDelegate.get(params1)).called(equals(2));
      });
    });

    test('fails to invalidate all if delegate fails', () {
      final error = StdinException("error");
      when(cacheDelegate.get(any)).thenReturnOneByOne([null, validEntity]);
      when(cacheDelegate.invalidateAll()).thenThrow(error);

      FakeAsync().run((async) {
        final List<Entity<String>?> values = [];
        service.getData(params1).listen((event) {
          values.add(event);
        });

        async.flushMicrotasks();
        expect(
            values,
            equals([null])
        );

        expect(
            service.invalidateAll(),
            throwsA(TypeMatcher<StdinException>())
        );
        async.flushMicrotasks();

        expect(
            values,
            equals([null])
        );
      });
    });

    test('deletes cache and updates from delegate', () {
      when(cacheDelegate.get(any)).thenReturnOneByOne([null, null]);
      FakeAsync().run((async) {
        final List<Entity<String>?> values = [];
        service.getData(params1).listen((event) {
          values.add(event);
        });

        async.flushMicrotasks();
        expect(
            values,
            equals([null])
        );

        service.delete(params1);
        async.flushMicrotasks();

        expect(
            values,
            equals([null, null])
        );
        verify(cacheDelegate.delete(params1));
        verify(cacheDelegate.get(params1)).called(equals(2));
      });
    });

    test('fails to delete if delegate fails', () {
      final error = StdinException("error");
      when(cacheDelegate.get(any)).thenReturnOneByOne([null, validEntity]);
      when(cacheDelegate.delete(any)).thenThrow(error);

      FakeAsync().run((async) {
        final List<Entity<String>?> values = [];
        service.getData(params1).listen((event) {
          values.add(event);
        });

        async.flushMicrotasks();
        expect(
            values,
            equals([null])
        );

        expect(
            service.delete(params1),
            throwsA(TypeMatcher<StdinException>())
        );
        async.flushMicrotasks();

        expect(
            values,
            equals([null])
        );
      });
    });
  });
}