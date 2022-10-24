import 'package:dartlcemodel/dartlcemodel_lce.dart';

/// [LceState] extensions
extension LceStateUtils<DATA_1 extends Object> on LceState<DATA_1> {
  /// Runs transformation [block] catching any error and wrapping it to [LceState.Error]:
  /// - The output data will be null
  /// - The data will be invalid
  LceState<DATA_2> catchToLce<DATA_2 extends Object>(LceState<DATA_2> Function (LceState<DATA_1>) block) {
    try {
      return block(this);
    } on Exception catch(e) {
      return LceState.error(null, false, e);
    }
  }

  /// Maps data in LceState with [mapper]
  LceState<DATA_2> map<DATA_2 extends Object>(DATA_2 Function(DATA_1) mapper) {
    final stateData = data;
    return when(
        loading: (state) => LceState.loading(
            null != stateData ? mapper(stateData) : null,
            state.dataIsValid,
            state.type
        ),
        content: (state) => LceState.content(
            mapper(state.data),
            state.dataIsValid
        ),
        error: (state) => LceState.error(
            null != stateData ? mapper(stateData) : null,
            state.dataIsValid,
            state.error
        ),
        terminated: () => LceState.terminated()
    );
  }

  /// Substitutes a state with empty data with empty data with state produced by [block]
  LceState<DATA_1> mapEmptyData(LceState<DATA_1> Function (LceState<DATA_1>) block) {
    if (null == data) {
      return block(this);
    } else {
      return this;
    }
  }

  /// Substitutes an item in a state with empty data with item produced by [block]
  LceState<DATA_1> mapEmptyDataItem(DATA_1 Function () block) {
    if (null != data) {
      return this;
    } else {
      return when(
        loading: (state) => LceState.loading(block(), state.dataIsValid, state.type),
        content: (state) => LceState.content(block(), state.dataIsValid),
        error: (state) => LceState.error(block(), state.dataIsValid, state.error),
        terminated: () => LceState.terminated()
      );
    }
  }

  /// Combines two Lce states.
  /// Here is the result state matrix
  /// | Receiver   | other      | Result     |
  /// |------------|------------|------------|
  /// | Loading    | Loading    | Loading    |
  /// | Loading    | Content    | Loading    |
  /// | Loading    | Error      | Error      |
  /// | Loading    | Terminated | Terminated |
  /// | Content    | Loading    | Loading    |
  /// | Content    | Content    | Content*   |
  /// | Content    | Error      | Error      |
  /// | Content    | Terminated | Terminated |
  /// | Error      | Loading    | Error      |
  /// | Error      | Content    | Error      |
  /// | Error      | Error      | Error      |
  /// | Error      | Terminated | Terminated |
  /// | Terminated | Loading    | Terminated |
  /// | Terminated | Content    | Terminated |
  /// | Terminated | Error      | Terminated |
  /// | Terminated | Terminated | Terminated |
  ///
  /// - Receiver - An Lce state that has a priority in final state resolution
  /// - [other] Other state to combine with
  /// - [mapper] Data mapper function. Returning null from it means data is not ready and will result
  ///   in loading state even if both states has data. You may return null-value of any kind to alter resulting state.
  LceState<DATA_3> combine<DATA_2 extends Object, DATA_3 extends Object>(
    LceState<DATA_2> other,
    DATA_3? Function(DATA_1? data1, DATA_2? data2) mapper
  ) {
    final data3 = mapper(data, other.data);
    final isValid = null != data3 && dataIsValid && other.dataIsValid;

    return when(
        loading: (state) => other.whenElse(
            error: (state2) => LceState.error(data3, isValid, state2.error),
            terminated: () => LceState.terminated(),
            onElse: (state2) => LceState.loading(data3, isValid, state.type)
        ),
        content: (state) => other.when(
            error: (state2) => LceState.error(data3, isValid, state2.error),
            terminated: () => LceState.terminated(),
            loading: (state2) => LceState.loading(data3, isValid, state2.type),
            content: (state2) => null == data3
                ? const LceState.loading(null, false)
                : LceState.content(data3, isValid)
        ),
        error: (state) => other.whenElse(
            terminated: () => LceState.terminated(),
            onElse: (state2) => LceState.error(data3, isValid, state.error)
        ),
        terminated: () => LceState.terminated()
    );
  }
}