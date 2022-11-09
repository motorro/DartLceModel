
import 'dart:isolate';

import 'package:dartlcemodel/dartlcemodel_utils.dart';

import 'asyncCacheDelegate.dart';
import 'entity/entity.dart';


/// [AsyncCacheDelegate] that runs operations in [Isolate]
/// [D] - data type to store
/// [P] - params type
class IsolateCacheDelegate<D extends Object, P extends Object> implements AsyncCacheDelegate<D, P> {
  /// IO delegate
  final AsyncCacheDelegate<D, P> _delegate;

  SendPort? _sendPort;
  Isolate? _actor;

  /// Constructor
  /// [_delegate] Async delegate to be wrapped with [Isolate]
  IsolateCacheDelegate(this._delegate);

  /// Disposes internal state
  void dispose(){
    _actor?.kill(priority: Isolate.immediate);
    _actor = null;
    _sendPort = null;
  }

  /// Runs a command and waits for response
  Future<Result<T?>> _run<T>(_Command<D, P> Function(SendPort) command) async {
    if (null == _actor) await _createActor();
    final ReceivePort port = ReceivePort();
    _sendPort!.send(command(port.sendPort));
    return await port.first;
  }

  /// Creates port and actor
  Future<void> _createActor() async {
    final receivePort = ReceivePort();
    _actor = await Isolate.spawn(
        _actorLogic<D, P>,
        _IsolateInit(receivePort.sendPort, _delegate)
    );
    _sendPort = await receivePort.first;
  }

  /// Actor logic
  static void _actorLogic<D extends Object, P extends Object>(_IsolateInit<D, P> init) async {
    final receivePort = ReceivePort();
    init.sender.send(receivePort.sendPort);

    final delegate = init.delegate;

    await for (final _Command<D, P> command in receivePort) {
      command.when(
          get: (params) async {
            command.sender.send(await delegate.get(params).toResult());
          },
          save: (params, data) async {
            command.sender.send(await delegate.save(params, data).toResult());
          },
          invalidate: (params) async {
            command.sender.send(await delegate.invalidate(params).toResult());
          },
          invalidateAll: () async {
            command.sender.send(await delegate.invalidateAll().toResult());
          },
          delete: (params) async {
            command.sender.send(await delegate.delete(params).toResult());
          }
      );
    }
  }

  @override
  Future<Entity<D>?> get(P params) {
    return _run<Entity<D>>((sendPort) => _Command.get(sendPort, params)).then((result) => result.toFuture());
  }

  @override
  Future<void> save(P params, Entity<D> entity) {
    return _run((sendPort) => _Command.save(sendPort, params, entity)).then((result) => result.toFuture());
  }

  @override
  Future<void> invalidate(P params) {
    return _run((sendPort) => _Command.invalidate(sendPort, params)).then((result) => result.toFuture());
  }

  @override
  Future<void> invalidateAll() {
    return _run((sendPort) => _Command.invalidateAll(sendPort)).then((result) => result.toFuture());
  }

  @override
  Future<void> delete(P params) {
    return _run((sendPort) => _Command.delete(sendPort, params)).then((result) => result.toFuture());
  }
}

/// Extensions for isolate delegate
extension IsolateCacheDelegateExtension<D extends Object, P extends Object> on AsyncCacheDelegate<D, P> {
  /// Wraps [AsyncCacheDelegate] with [Isolate] for long-running operations
  AsyncCacheDelegate<D, P> isolated() => IsolateCacheDelegate(this);
}

/// Initializes actor
class _IsolateInit<D extends Object, P extends Object> {
  final SendPort sender;
  final AsyncCacheDelegate<D, P> delegate;

  const _IsolateInit(this.sender, this.delegate);
}

/// Actor command - sent to isolate
abstract class _Command<D extends Object, P extends Object> {
  final SendPort sender;

  const _Command(this.sender);

  const factory _Command.get(SendPort sender, P params) = _Get;
  const factory _Command.save(SendPort sender, P params, Entity<D> data) = _Save;
  const factory _Command.invalidate(SendPort sender, P params) = _Invalidate;
  const factory _Command.invalidateAll(SendPort sender) = _InvalidateAll;
  const factory _Command.delete(SendPort sender, P params) = _Delete;

  T when<T>({
    required T Function(P params) get,
    required T Function(P params, Entity<D> data) save,
    required T Function(P params) invalidate,
    required T Function() invalidateAll,
    required T Function(P params) delete,
  });
}

class _Get<D extends Object, P extends Object> extends _Command<D, P> {
  final P params;
  const _Get(sender, this.params) : super(sender);

  @override
  T when<T>({
    required T Function(P params) get,
    required T Function(P params, Entity<D> data) save,
    required T Function(P params) invalidate,
    required T Function() invalidateAll,
    required T Function(P params) delete
  }) => get(params);
}

class _Save<D extends Object, P extends Object> extends _Command<D, P> {
  final P params;
  final Entity<D> data;
  const _Save(sender, this.params, this.data) : super(sender);

  @override
  T when<T>({
    required T Function(P params) get,
    required T Function(P params, Entity<D> data) save,
    required T Function(P params) invalidate,
    required T Function() invalidateAll,
    required T Function(P params) delete
  }) => save(params, data);
}

class _Invalidate<D extends Object, P extends Object> extends _Command<D, P> {
  final P params;
  const _Invalidate(sender, this.params) : super(sender);

  @override
  T when<T>({
    required T Function(P params) get,
    required T Function(P params, Entity<D> data) save,
    required T Function(P params) invalidate,
    required T Function() invalidateAll,
    required T Function(P params) delete
  }) => invalidate(params);
}

class _InvalidateAll<D extends Object, P extends Object> extends _Command<D, P> {
  const _InvalidateAll(sender) : super(sender);

  @override
  T when<T>({
    required T Function(P params) get,
    required T Function(P params, Entity<D> data) save,
    required T Function(P params) invalidate,
    required T Function() invalidateAll,
    required T Function(P params) delete
  }) => invalidateAll();
}

class _Delete<D extends Object, P extends Object> extends _Command<D, P> {
  final P params;
  const _Delete(sender, this.params) : super(sender);

  @override
  T when<T>({
    required T Function(P params) get,
    required T Function(P params, Entity<D> data) save,
    required T Function(P params) invalidate,
    required T Function() invalidateAll,
    required T Function(P params) delete
  }) => delete(params);
}


