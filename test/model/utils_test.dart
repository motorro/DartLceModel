import 'dart:async';

import 'package:dartlcemodel/dartlcemodel_lce.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

void main() {
  group('flatMapSingleData', () {
    provider(int data) async => Future.value(data * 2);

    test('returns empty loading', () {
      final source = Stream<LceState<int>>.value(LceState.loading(null, false));

      expect(
          source.flatMapSingleData(provider),
          emitsInOrder([LceState<int>.loading(null, false)])
      );
    });

    test('runs provider for each data emission', () {
      final source = Stream.fromIterable([1,2,3]).map((event) => LceState.content(event, true));

      expect(
        source.flatMapSingleData(provider),
        emitsInOrder([2, 4, 6].map((e) => LceState.content(e, true)))
      );
    });

    test('maps provider error to LceError', () {
      final error = Exception('error');
      final source = Stream<LceState<int>>.value(LceState.content(1, true));
      errorProvider(int data) => Future<int>.error(error);

      expect(
        source.flatMapSingleData(errorProvider),
        emitsInOrder([LceState<int>.error(null, false, error)])
      );
    });
  });

  group('withRefresh', () {
    test('refreshes data on emission', () {
      final useCase = _RefreshingUseCase();
      final List<LceState<int>> values = [];
      final refresh = StreamController<int>();
      FakeAsync().run((async) {
        useCase.withRefresh(refresh.stream).listen((event) { values.add(event); });

        refresh.add(1);
        async.flushMicrotasks();
        refresh.add(2);
        async.flushMicrotasks();
        refresh.add(3);
        async.flushMicrotasks();

        expect(
            values,
            equals([
              LceState.content(1, true),
              LceState.content(2, true),
              LceState.content(3, true)
            ])
        );
      });
    });
  });
}

class _RefreshingUseCase implements LceUseCase<int> {
  var _refreshCount = 0;
  final _controller = StreamController<int>();

  @override
  Stream<LceState<int>> get state => _controller.stream.map((event) => LceState.content(event, true));

  @override
  Future<void> refresh() async {
    _controller.add(++_refreshCount);
  }
}