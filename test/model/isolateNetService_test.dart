import 'dart:io';

import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';
import 'package:dartlcemodel/src/model/service/isolateNetService.dart';
import 'package:test/test.dart';

void main() {
  final String params = 'params';
  final Entity<String> entity = Entity.create('data', AlwaysValid.instance);

  group('Isolate net service', () {

    test('returns data', () {
      final isolateService = IsolateNetService(_TestNetService(value: entity));
      expect(
          isolateService.get(params),
          completion(equals(entity))
      );
    });

    test('throws on error when getting', () {
      final isolateDelegate = IsolateNetService(_TestNetService(value: entity, throws: true));
      expect(
          isolateDelegate.get(params),
          throwsA(isA<StdinException>())
      );
    });
  });
}

class _TestNetService implements NetService<String, String> {
  final Entity<String> _value;
  final bool _throws;

  const _TestNetService({ required Entity<String> value, bool throws = false}) : _value = value, _throws = throws;

  @override
  Future<Entity<String>> get(String params) async => _ret(() => _value);

  T _ret<T>(T Function() block) {
    if (_throws) {
      throw StdinException("error");
    } else {
      return block();
    }
  }
}