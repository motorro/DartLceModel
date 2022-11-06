import 'dart:io';

import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/src/cache/isolateCacheDelegate.dart';
import 'package:test/test.dart';

void main() {
  final String params = 'params';
  final Entity<String> entity = Entity.create('data', AlwaysValid.instance);

  group('Sync friend delegate', () {
    test('returns null when nothing cached', () {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate());
      expect(
          isolateDelegate.get(params),
          completion(isNull)
      );
    });

    test('returns cached data', () {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate(value: entity));
      expect(
          isolateDelegate.get(params),
          completion(equals(entity))
      );
    });

    test('throws on error when getting', () {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate(throws: true));
      expect(
          isolateDelegate.get(params),
          throwsA(isA<StdinException>())
      );
    });

    test('saves data', () async {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate());
      await isolateDelegate.save(params, entity);
      final value = await isolateDelegate.get(params);

      expect(value, equals(entity));
    });

    test('throws on error when saving', () {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate(throws: true));
      expect(
          isolateDelegate.save(params, entity),
          throwsA(isA<StdinException>())
      );
    });

    test('invalidates data', () async {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate(value: entity));
      await isolateDelegate.invalidate(params);
      final value = await isolateDelegate.get(params);

      expect(value!.isValid(), isFalse);
    });

    test('throws on error when invalidating', () {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate(throws: true));
      expect(
          isolateDelegate.invalidate(params),
          throwsA(isA<StdinException>())
      );
    });

    test('invalidates all data', () async {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate(value: entity));
      await isolateDelegate.invalidateAll();
      final value = await isolateDelegate.get(params);

      expect(value!.isValid(), isFalse);
    });

    test('throws on error when invalidating all data', () {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate(throws: true));
      expect(
          isolateDelegate.invalidateAll(),
          throwsA(isA<StdinException>())
      );
    });

    test('deletes data', () async {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate(value: entity));
      await isolateDelegate.delete(params);
      final value = await isolateDelegate.get(params);

      expect(value, isNull);
    });

    test('throws on error when deleting', () {
      final isolateDelegate = IsolateCacheDelegate(_TestDelegate(throws: true));
      expect(
          isolateDelegate.delete(params),
          throwsA(isA<StdinException>())
      );
    });
  });
}

class _TestDelegate implements AsyncCacheDelegate<String, String> {
  Entity<String>? _value;
  final bool _throws;

  _TestDelegate({ Entity<String>? value, bool throws = false}) : _value = value, _throws = throws;

  @override
  Future<Entity<String>?> get(String params) async {
    return _ret(() {
      return _value;
    });
  }

  @override
  Future<void> save(String params, Entity<String> entity) async {
    _ret(() {
      _value = entity;
    });
  }

  @override
  Future<void> invalidate(String params) async {
    _ret(() { _value = _value?.invalidate(); });
  }

  @override
  Future<void> invalidateAll() async {
    _ret(() { _value = _value?.invalidate(); });
  }

  @override
  Future<void> delete(String params) async {
    _ret(() { _value = null; });
  }

  T _ret<T>(T Function() block) {
    if (_throws) {
      throw StdinException("error");
    } else {
      return block();
    }
  }
}
