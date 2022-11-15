
import 'dart:isolate';

import 'package:dartlcemodel/dartlcemodel_utils.dart';
import 'package:dartlcemodel/src/cache/entity/entity.dart';

import './net_service.dart';

class IsolateNetService<D extends Object, P extends Object> implements NetService<D, P> {
  /// Delegate service
  final NetService <D, P> _delegate;

  SendPort? _sendPort;
  Isolate? _actor;

  /// Constructor
  /// [_delegate] Async delegate to be wrapped with [Isolate]
  IsolateNetService(this._delegate);

  /// Disposes internal state
  void dispose(){
    _actor?.kill(priority: Isolate.immediate);
    _actor = null;
    _sendPort = null;
  }

  /// Runs a command and waits for response
  Future<Result<T>> _run<T extends Object>(_Command<D, P> Function(SendPort) command) async {
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
          }
      );
    }
  }

  @override
  Future<Entity<D>> get(P params) {
    return _run<Entity<D>>((sendPort) => _Command.get(sendPort, params)).then((result) => result.toFuture());
  }
}

/// Extensions for isolate delegate
extension IsolateNetServiceExtension<D extends Object, P extends Object> on NetService<D, P> {
  /// Wraps [AsyncCacheDelegate] with [Isolate] for long-running operations
  NetService<D, P> isolated() => IsolateNetService(this);
}

/// Initializes actor
class _IsolateInit<D extends Object, P extends Object> {
  final SendPort sender;
  final NetService<D, P> delegate;

  const _IsolateInit(this.sender, this.delegate);
}

/// Actor command - sent to isolate
abstract class _Command<D extends Object, P extends Object> {
  final SendPort sender;

  const _Command(this.sender);

  const factory _Command.get(SendPort sender, P params) = _Get;

  T when<T>({
    required T Function(P params) get
  });
}

class _Get<D extends Object, P extends Object> extends _Command<D, P> {
  final P params;
  const _Get(sender, this.params) : super(sender);

  @override
  T when<T>({
    required T Function(P params) get
  }) => get(params);
}
