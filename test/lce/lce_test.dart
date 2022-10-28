import 'dart:io';

import 'package:dartlcemodel/dartlcemodel_lce.dart';
import 'package:test/test.dart';

void main() {
  group('Loading', () {
    test('dispatches when', () {
      final loading = LceState.loading(1, false);
      bool called = false;

      loading.when (
          loading: (state) {
            called = true;
            expect(
              state,
              equals(loading)
            );
          },
          content: (_) => throw Exception('unexpected Content'),
          error: (_) => throw Exception('unexpected Error'),
          terminated: () => throw Exception('unexpected Terminated')
      );
      expect(called, isTrue);
    });

    test('dispatches whenElse', () {
      final loading = LceState.loading(1, false);
      bool branchCalled = false;
      bool elseCalled = false;

      loading.whenElse (
          loading: (state) {
            branchCalled = true;
            expect(
              state,
              equals(loading)
            );
          },
          content: (_) => throw Exception('unexpected Content'),
          error: (_) => throw Exception('unexpected Error'),
          terminated: () => throw Exception('unexpected Terminated'),
          onElse: (_) => throw Exception('unexpected Else')
      );
      expect(branchCalled, isTrue);

      loading.whenElse(onElse: (state) {
        elseCalled = true;
        expect(
            state,
            equals(loading)
        );
      });
      expect(elseCalled, isTrue);
    });
  });

  group('Content', () {
    test('dispatches when', () {
      final content = LceState.content(1, true);
      bool called = false;

      content.when (
          loading: (_) => throw Exception('unexpected Loading'),
          content: (state) {
            called = true;
            expect(
                state,
                equals(content)
            );
          },
          error: (_) => throw Exception('unexpected Error'),
          terminated: () => throw Exception('unexpected Terminated')
      );
      expect(called, isTrue);
    });

    test('dispatches whenElse', () {
      final content = LceState.content(1, false);
      bool branchCalled = false;
      bool elseCalled = false;

      content.whenElse (
          loading: (_) => throw Exception('unexpected Loading'),
          content: (state) {
            branchCalled = true;
            expect(
                state,
                equals(content)
            );
          },
          error: (_) => throw Exception('unexpected Error'),
          terminated: () => throw Exception('unexpected Terminated'),
          onElse: (_) => throw Exception('unexpected Else')
      );
      expect(branchCalled, isTrue);

      content.whenElse(onElse: (state) {
        elseCalled = true;
        expect(
            state,
            equals(content)
        );
      });
      expect(elseCalled, isTrue);
    });
  });

  group('Error', () {
    test('dispatches when', () {
      final error = LceState.error(1, true, StdinException("error"));
      bool called = false;

      error.when (
          loading: (_) => throw Exception('unexpected Loading'),
          content: (_) => throw Exception('unexpected Content'),
          error: (state) {
            called = true;
            expect(
                state,
                equals(error)
            );
          },
          terminated: () => throw Exception('unexpected Terminated')
      );
      expect(called, isTrue);
    });

    test('dispatches whenElse', () {
      final error = LceState.error(1, false, StdinException("error"));
      bool branchCalled = false;
      bool elseCalled = false;

      error.whenElse (
          loading: (_) => throw Exception('unexpected Loading'),
          content: (_) => throw Exception('unexpected Content'),
          error: (state) {
            branchCalled = true;
            expect(
                state,
                equals(error)
            );
          },
          terminated: () => throw Exception('unexpected Terminated'),
          onElse: (_) => throw Exception('unexpected Else')
      );
      expect(branchCalled, isTrue);

      error.whenElse(onElse: (state) {
        elseCalled = true;
        expect(
            state,
            equals(error)
        );
      });
      expect(elseCalled, isTrue);
    });
  });

  group('Terminated', () {
    test('dispatches when', () {
      final terminated = LceState.terminated;
      bool called = false;

      terminated.when (
          loading: (_) => throw Exception('unexpected Loading'),
          content: (_) => throw Exception('unexpected Content'),
          error: (_) => throw Exception('unexpected Content'),
          terminated: () { called = true; }
      );
      expect(called, isTrue);
    });

    test('dispatches whenElse', () {
      final terminated = LceState.terminated;
      bool branchCalled = false;
      bool elseCalled = false;

      terminated.whenElse (
          loading: (_) => throw Exception('unexpected Loading'),
          content: (_) => throw Exception('unexpected Content'),
          error: (_) => throw Exception('unexpected Content'),
          terminated: () { branchCalled = true; },
          onElse: (_) => throw Exception('unexpected Else')
      );
      expect(branchCalled, isTrue);

      terminated.whenElse(onElse: (state) {
        elseCalled = true;
        expect(
            state,
            equals(terminated)
        );
      });
      expect(elseCalled, isTrue);
    });
  });
}