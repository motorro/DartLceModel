import 'dart:async';

import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';

import 'cacheServiceCommand.dart';

/// Cache service implementation with [AsyncCacheDelegate]
/// [delegateFactory] Delegate to perform concrete caching operations
class AsyncDelegateCacheService<D extends Object, P extends Object> implements CacheService<D, P> {

  /// Cache delegate
  final AsyncCacheDelegate<D, P> _delegate;

  /// Service update controller
  late final StreamController<CacheServiceCommand<P>> _refreshController;

  /// Service refresh stream
  late final Stream<CacheServiceCommand<P>> _refreshStream;

  /// Constructor
  /// [_delegate] - Delegate for data storage
  AsyncDelegateCacheService(this._delegate) {
    _refreshController = StreamController();
    _refreshStream = _refreshController.stream.asBroadcastStream();
  }

  @override
  Stream<Entity<D>?> getData(P params) async* {
    yield await _delegate.get(params);
    await for (final command in _refreshStream) {
      if (command.isForMe(params)) {
        yield await _delegate.get(params);
      }
    }
  }

  @override
  Future<void> save(P params, Entity<D> entity) async {
    await _delegate.save(params, entity);
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
    await _delegate.invalidate(params);
    _emitCommand(() => _individual(params));
  }

  @override
  Future<void> invalidateAll() async {
    await _delegate.invalidateAll();
    _emitCommand(() => _all());
  }

  @override
  Future<void> delete(P params) async {
    await _delegate.delete(params);
    _emitCommand(() => _individual(params));
  }

  void _emitCommand(CacheServiceCommand<P> Function() block) {
    if (_refreshController.hasListener) {
      _refreshController.add(block());
    }
  }

  CacheServiceCommand<P> _individual(P params) {
    return Individual(params);
  }

  CacheServiceCommand<P> _all() {
    return All();
  }
}
