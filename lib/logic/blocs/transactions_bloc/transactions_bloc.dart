import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/constants/models/transactions_model.dart';
import 'package:montra/logic/api/expense/expense_api.dart';
import 'package:montra/logic/api/income/income_api.dart';
import 'package:montra/logic/api/transfer/transfer_api.dart';
import 'package:montra/logic/dio_factory.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';
part 'transactions_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc() : super(_Initial()) {
    on<TransactionsEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<_GetAllTransactions>(_getAllTransactions);
  }

  final _expenseApi = ExpenseApi(DioFactory().create());
  final _incomeApi = IncomeApi(DioFactory().create());
  final _transferApi = TransferApi(DioFactory().create());

  // Add this method to your TransactionsBloc class
  List<dynamic> getSortedTransactions(TransactionsModels transactionsModel) {
    // Create lists to hold all transaction types with their metadata
    List<Map<String, dynamic>> allTransactions = [];

    // Add expenses
    for (var expense in transactionsModel.expenses.expenses) {
      allTransactions.add({
        'createdAt': expense.createdAt,
        'data': expense,
        'type': 'expense',
      });
    }

    // Add incomes
    for (var income in transactionsModel.incomes.incomes) {
      allTransactions.add({
        'createdAt': income.createdAt,
        'data': income,
        'type': 'income',
      });
    }

    // Add transfers
    for (var transfer in transactionsModel.transfer.transfers) {
      allTransactions.add({
        'createdAt': transfer.createdAt,
        'data': transfer,
        'type': 'transfer',
      });
    }

    // Sort by createdAt in descending order (newest first)
    allTransactions.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

    return allTransactions;
  }

  Future<void> _getAllTransactions(
    _GetAllTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      emit(TransactionsState.inProgress());
      final expenses = await _expenseApi.getAllExpenses();
      final incomes = await _incomeApi.getAllIncomes();
      final transfers = await _transferApi.getAllIncomes();

      final transactions = TransactionsModels(
        transfer: transfers,
        incomes: incomes,
        expenses: expenses,
      );

      final sortedTransactions = getSortedTransactions(transactions);
      emit(
        TransactionsState.getAllTransactionSuccess(
          transactions: sortedTransactions,
        ),
      );
    } catch (e) {
      log.e('Error getting all transactions : $e');
      emit(TransactionsState.failure());
    }
  }
}
