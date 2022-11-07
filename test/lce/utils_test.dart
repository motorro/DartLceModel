import 'dart:io';

import 'package:dartlcemodel/dartlcemodel_lce.dart';
import 'package:test/test.dart';

void main() {
  group('combine', () {
    test('loading and loading result in loading', () {
      final state1 = LceState.loading(1, false);
      final state2 = LceState.loading(2, false, LoadingType.refreshing);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceLoading<int>>()
      );
      expect(
          state3.dataIsValid,
          isFalse
      );
      expect(
          (state3 as LceLoading).type,
          equals(LoadingType.loading)
      );
    });

    test('loading and content result in loading', () {
      final state1 = LceState.loading(1, false);
      final state2 = LceState.content(2, true);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceLoading<int>>()
      );
      expect(
          state3.dataIsValid,
          isFalse
      );
      expect(
          (state3 as LceLoading).type,
          equals(LoadingType.loading)
      );
    });

    test('loading and error result in error', () {
      final error = StdinException("error");
      final state1 = LceState.loading(1, false);
      final state2 = LceState.error(2, false, error);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceError<int>>()
      );
      expect(
          state3.dataIsValid,
          isFalse
      );
    });

    test('loading and terminated result in terminated', () {
      final state1 = LceState.loading(1, false);
      final state2 = LceState<int>.terminated();
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceTerminated<int>>()
      );
    });

    test('content and loading result in loading', () {
      final state1 = LceState.content(1, true);
      final state2 = LceState.loading(2, false, LoadingType.refreshing);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => d1! + d2!);

      expect(
          state3,
          isA<LceLoading<int>>()
      );
      expect(
          state3.dataIsValid,
          isFalse
      );
      expect(
          state3.data,
          equals(3)
      );
      expect(
          (state3 as LceLoading).type,
          equals(LoadingType.refreshing)
      );
    });

    test('content and content result in loading if mapper returns null', () {
      final state1 = LceState.content(1, false);
      final state2 = LceState.content(2, true);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceLoading<int>>()
      );
      expect(
          state3.dataIsValid,
          isFalse
      );
      expect(
          state3.data,
          isNull
      );
      expect(
          (state3 as LceLoading).type,
          equals(LoadingType.loading)
      );
    });

    test('content and content result in content if mapper returns non-null', () {
      final state1 = LceState.content(1, true);
      final state2 = LceState.content(2, true);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => d1! + d2!);

      expect(
          state3,
          isA<LceContent<int>>()
      );
      expect(
          state3.dataIsValid,
          isTrue
      );
      expect(
          state3.data,
          equals(3)
      );
    });

    test('content and error result in error', () {
      final error = StdinException("error");
      final state1 = LceState.content(1, true);
      final state2 = LceState.error(2, false, error);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => d1! + d2!);

      expect(
          state3,
          isA<LceError<int>>()
      );
      expect(
          state3.dataIsValid,
          isFalse
      );
      expect(
          state3.data,
          equals(3)
      );
      expect(
          (state3 as LceError).error,
          error
      );
    });

    test('content and terminated result in terminated', () {
      final state1 = LceState.content(1, true);
      final state2 = LceState<int>.terminated();
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceTerminated<int>>()
      );
    });

    test('error and loading result in error', () {
      final error = StdinException("error");
      final state1 = LceState.error(1, false, error);
      final state2 = LceState.loading(2, false, LoadingType.refreshing);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => d1! + d2!);

      expect(
          state3,
          isA<LceError<int>>()
      );
      expect(
          state3.dataIsValid,
          isFalse
      );
      expect(
          state3.data,
          equals(3)
      );
      expect(
          (state3 as LceError).error,
          equals(error)
      );
    });

    test('error and content result in error', () {
      final error = StdinException("error");
      final state1 = LceState.error(1, false, error);
      final state2 = LceState.content(2, true);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => d1! + d2!);

      expect(
          state3,
          isA<LceError<int>>()
      );
      expect(
          state3.dataIsValid,
          isFalse
      );
      expect(
          state3.data,
          equals(3)
      );
      expect(
          (state3 as LceError).error,
          equals(error)
      );
    });

    test('error and error result in receiver error', () {
      final error1 = StdinException("error 1");
      final error2 = StdinException("error 2");
      final state1 = LceState.error(1, false, error1);
      final state2 = LceState.error(2, true, error2);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => d1! + d2!);

      expect(
          state3,
          isA<LceError<int>>()
      );
      expect(
          state3.dataIsValid,
          isFalse
      );
      expect(
          state3.data,
          equals(3)
      );
      expect(
          (state3 as LceError).error,
          equals(error1)
      );
    });

    test('error and terminated result in terminated', () {
      final error = StdinException("error");
      final state1 = LceState.error(1, false, error);
      final state2 = LceState<int>.terminated();
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceTerminated<int>>()
      );
    });

    test('terminated and loading result in terminated', () {
      final state1 = LceState.terminated();
      final state2 = LceState<int>.loading(null, false);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceTerminated<int>>()
      );
    });

    test('terminated and content result in terminated', () {
      final state1 = LceState.terminated();
      final state2 = LceState.content(1, true);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceTerminated<int>>()
      );
    });

    test('terminated and error result in terminated', () {
      final error = StdinException("error");
      final state1 = LceState.terminated();
      final state2 = LceState.error(1, false, error);
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceTerminated<int>>()
      );
    });

    test('terminated and terminated result in terminated', () {
      final state1 = LceState<int>.terminated();
      final state2 = LceState<int>.terminated();
      final state3 = state1.combine<int, int>(state2, (d1, d2) => null);

      expect(
          state3,
          isA<LceTerminated<int>>()
      );
    });
  });

  group('catchToLce', () {
    test('bypasses mapped state', () {
      final state1 = LceState.content(1, true);
      final state2 = state1.catchToLce((it) => LceState.content((it.data ?? 0) + 1, it.dataIsValid));

      expect(
          state2,
          equals(LceState.content(2, true))
      );
    });

    test('catches error to LCE', () {
      final error = StdinException("error");
      final state1 = LceState.content(1, true);
      final state2 = state1.catchToLce<int>((state) => throw error);

      expect(
        state2,
        equals(LceState<int>.error(null, false, error))
      );
    });
  });

  group('mapEmptyData', () {
    test('substitutes empty loading', () {
      final original = LceState<int>.loading(null, false);
      final substitute = LceState.content(10, true);

      expect(
        original.mapEmptyData((state) => substitute),
        equals(substitute)
      );
    });

    test('substitutes empty error', () {
      final original = LceState<int>.error(null, false, StdinException("error"));
      final substitute = LceState.content(10, true);
      expect(
          original.mapEmptyData((state) => substitute),
          equals(substitute)
      );
    });

    test('substitutes termination', () {
      final original = LceState<int>.terminated();
      final substitute = LceState.content(10, true);
      expect(
          original.mapEmptyData((state) => substitute),
          equals(substitute)
      );
    });

    test('passes non-empty loading', () {
      final original = LceState.loading(10, true);
      final substitute = LceState.content(10, true);
      expect(
          original.mapEmptyData((state) => substitute),
          equals(original)
      );
    });

    test('passes non-empty error', () {
      final original = LceState.error(10, true, StdinException("error"));
      final substitute = LceState.content(10, true);
      expect(
          original.mapEmptyData((state) => substitute),
          equals(original)
      );
    });
  });

  group('mapEmptyDataItem', () {
    test('substitutes empty loading item', () {
      final original = LceState<int>.loading(null, false);
      final substitute = 10;

      expect(
          original.mapEmptyDataItem(() => substitute),
          LceState.loading(10, false)
      );
    });

    test('substitutes empty error item', () {
      final error = StdinException("error");
      final original = LceState<int>.error(null, false, error);
      final substitute = 10;
      expect(
          original.mapEmptyDataItem(() => substitute),
          equals(LceState.error(10, false, error))
      );
    });

    test('substitutes termination item', () {
      final original = LceState<int>.terminated();
      final substitute = 10;
      expect(
          original.mapEmptyDataItem(() => substitute),
          equals(LceState<int>.terminated())
      );
    });

    test('passes non-empty loading item', () {
      final original = LceState.loading(10, true);
      final substitute = 100;
      expect(
          original.mapEmptyDataItem(() => substitute),
          equals(original)
      );
    });

    test('passes non-empty error item', () {
      final original = LceState.error(10, true, StdinException("error"));
      final substitute = 100;
      expect(
          original.mapEmptyDataItem(() => substitute),
          equals(original)
      );
    });
  });
}
