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
    on<_FilterTransactions>(_filterTransactions);
  }

  final _expenseApi = ExpenseApi(DioFactory().create());
  final _incomeApi = IncomeApi(DioFactory().create());
  final _transferApi = TransferApi(DioFactory().create());

  // Add this method to your TransactionsBloc class
  List<Map<String, dynamic>> getSortedTransactions(
    TransactionsModels transactionsModel,
  ) {
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

  Future<void> _filterTransactions(
    _FilterTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      emit(const TransactionsState.inProgress());

      final expenses = await _expenseApi.getAllExpenses();
      final incomes = await _incomeApi.getAllIncomes();
      final transfers = await _transferApi.getAllIncomes();

      final transactions = TransactionsModels(
        transfer: transfers,
        incomes: incomes,
        expenses: expenses,
      );

      List<Map<String, dynamic>> all = getSortedTransactions(transactions);

      // Apply type filter
      if (event.type.toLowerCase() != 'all') {
        all =
            all.where((tx) => tx['type'] == event.type.toLowerCase()).toList();
      }

      // Apply category filter
      if (event.categories != null && event.categories!.isNotEmpty) {
        all =
            all.where((tx) {
              final data = tx['data'];
              return event.categories!.contains(
                data.category.toString().toLowerCase(),
              );
            }).toList();
      }

      // Apply sort
      switch (event.sortBy?.toLowerCase()) {
        case 'highest':
          all.sort((a, b) => b['data'].amount.compareTo(a['data'].amount));
          break;
        case 'lowest':
          all.sort((a, b) => a['data'].amount.compareTo(b['data'].amount));
          break;
        case 'oldest':
          all.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
          break;
        case 'newest':
        default:
          all.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
      }

      emit(TransactionsState.getAllTransactionSuccess(transactions: all));
    } catch (e) {
      log.e('Filter error: $e');
      emit(const TransactionsState.failure());
    }
  }
}
