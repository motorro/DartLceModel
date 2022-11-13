import 'dart:async';

import 'package:dartlcemodel/dartlcemodel_lce.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';
import 'package:flutter/material.dart';

/// A widget that handles [LceUseCase] creation and re-subscription when [params] change
abstract class LceWidget<D extends Object> extends StatefulWidget {
  final LceState<D> initial;

  /// Constructor
  /// [key] - widget key
  /// [initial] - the default state to show while waiting for usecase emission
  const LceWidget({Key? key, this.initial = const LceState.loading(null, false)}) : super(key: key);

  /// factory producing the [LceUseCase] that will be subscribed
  LceUseCase<D> factory();

  /// Checks if the use-case should be re-created when widget data changes
  bool resubscribe(LceWidget<D> newWidget, LceWidget<D> oldWidget) => true;

  /// Describes the part of the user interface represented by this widget given the [LceState].
  /// [lceState] current [LceState]
  /// [refresh] Refresh handler
  Widget processState(LceState<D> lceState, Future<void> Function() refresh);

  @override
  State<LceWidget<D>> createState() => _LceWidgetState();
}

class _LceWidgetState<D extends Object> extends State<LceWidget<D>> {
  LceUseCase<D>? _useCase;
  StreamSubscription<LceState<D>>? _subscription;
  late LceState<D> _lceState;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(LceWidget<D> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resubscribe(widget, oldWidget)) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _unsubscribe();
  }

  _subscribe() {
    _lceState = widget.initial;
    _useCase = widget.factory();
    _subscription = _useCase!.state.listen((newLceState) {
      setState(() { _lceState = newLceState; });
    });
  }

  _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _useCase = null;
  }

  Future<void> _refresh() async {
    return _useCase?.refresh() ?? Future.value();
  }

  @override
  Widget build(BuildContext context) => widget.processState(_lceState, _refresh);
}
