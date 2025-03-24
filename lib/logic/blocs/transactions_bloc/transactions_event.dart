part of 'transactions_bloc.dart';

@freezed
class TransactionsEvent with _$TransactionsEvent {
  const factory TransactionsEvent.started() = _Started;
  const factory TransactionsEvent.getAllTransactions() = _GetAllTransactions;
  const factory TransactionsEvent.filterTransactions({
    required String type, // income, expense, transfer, or all
    String? sortBy, // highest, lowest, newest, oldest
    List<String>? categories, // category filters
  }) = _FilterTransactions;
}
