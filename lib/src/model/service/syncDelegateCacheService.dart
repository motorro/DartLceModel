import 'dart:async';

import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';

/// Cache service implementation with [CacheDelegate]
/// [delegate] Delegate to perform concrete caching operations
class SyncDelegateCacheService<D extends Object, P extends Object> implements CacheService<D, P> {

  /// Cache delegate
  final CacheDelegate<D, P> _delegate;

  /// Service update controller
  late final StreamController<_SyncDelegateCacheServiceCommand<P>> _refreshController;

  /// Service refresh stream
  late final Stream<_SyncDelegateCacheServiceCommand<P>> _refreshStream;

  SyncDelegateCacheService(this._delegate) {
    _refreshController = StreamController();
    _refreshStream = _refreshController.stream.asBroadcastStream();
  }

  @override
  Stream<Entity<D>?> getData(P params) async* {
    yield _delegate.get(params);
    await for (final command in _refreshStream) {
      if (command.isForMe(params)) {
        yield _delegate.get(params);
      }
    }
  }

  @override
  Future<void> save(P params, Entity<D> entity) async {
    _delegate.save(params, entity);
    _emitCommand(() => _individual(params));
  }

  @override
  Future<void> refetch(P params) async {
    _emitCommand(() => _individual(params));
  }

  @override
  Future<void> refetchAll() async {
    _emitCommand(() => _all());
  }

  @override
  Future<void> invalidate(P params) async {
    _delegate.invalidate(params);
    _emitCommand(() => _individual(params));
  }

  @override
  Future<void> invalidateAll() async {
    _delegate.invalidateAll();
    _emitCommand(() => _all());
  }

  @override
  Future<void> delete(P params) async {
    _delegate.delete(params);
    _emitCommand(() => _individual(params));
  }

  void _emitCommand(_SyncDelegateCacheServiceCommand<P> Function() block) {
    if (_refreshController.hasListener) {
      _refreshController.add(block());
    }
  }

  _SyncDelegateCacheServiceCommand<P> _individual(P params) {
    return _Individual(params);
  }

  _SyncDelegateCacheServiceCommand<P> _all() {
    return _All();
  }
}

/// Refresh command to send through [refreshChannel]
abstract class _SyncDelegateCacheServiceCommand<P extends Object> {
  /// Called by actor to check if the command concerns him
  bool isForMe(P params);

  /// Emulates sealed class with every state callback required
  T when<T>({
    required T Function(_Individual<P> state) individual,
    required T Function() all
  });
}

/// Refreshes actor with bound [params]
class _Individual<P extends Object> implements _SyncDelegateCacheServiceCommand<P> {
  final P _params;

  const _Individual(this._params);

  @override
  bool isForMe(P params) {
    return params == _params;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Individual &&
          runtimeType == other.runtimeType &&
          _params == other._params;

  @override
  int get hashCode => "_Individual".hashCode ^ _params.hashCode;

  @override
  String toString() {
    return '_Individual{_params: $_params}';
  }

  @override
  T when<T>({
    required T Function(_Individual<P> state) individual,
    required T Function() all
  }) => individual(this);
}

/// Refreshes all actors
class _All<P extends Object> implements _SyncDelegateCacheServiceCommand<P> {

  const _All();

  @override
  bool isForMe(P params) {
    return true;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is _All;

  @override
  int get hashCode => "_All".hashCode;

  @override
  String toString() => '_All';

  @override
  T when<T>({
    required T Function(_Individual<Never> state) individual,
    required T Function() all
  }) => all();
}
