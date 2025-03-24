part of 'transactions_bloc.dart';

@freezed
class TransactionsState with _$TransactionsState {
  const factory TransactionsState.initial() = _Initial;
  const factory TransactionsState.inProgress() = _InProgress;
  const factory TransactionsState.failure() = _Failure;
  const factory TransactionsState.getAllTransactionSuccess({
    required List<dynamic> transactions,
  }) = _GetAllTransactionSuccess;
}
