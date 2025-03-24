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
      final transfers = await _transferApi.getAllTransfers();

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

      // Fetch all transactions
      final expenses = await _expenseApi.getAllExpenses();
      final incomes = await _incomeApi.getAllIncomes();
      final transfers =
          await _transferApi.getAllTransfers(); // correct if needed

      final all = <Map<String, dynamic>>[];

      // Merge and label data
      for (final e in expenses.expenses) {
        all.add({'data': e, 'type': 'expense', 'createdAt': e.createdAt});
      }
      for (final i in incomes.incomes) {
        all.add({'data': i, 'type': 'income', 'createdAt': i.createdAt});
      }
      for (final t in transfers.transfers) {
        all.add({'data': t, 'type': 'transfer', 'createdAt': t.createdAt});
      }

      // Apply filters
      List<Map<String, dynamic>> filtered = all;

      // Type filter
      if (event.type.toLowerCase() != "all") {
        filtered = filtered.where((t) => t['type'] == event.type).toList();
      }

      // Category filter
      if (event.categories != null && event.categories!.isNotEmpty) {
        filtered =
            filtered.where((t) {
              final type = t['type'];
              if (type == 'transfer') return false;

              final description = (t['data'].description ?? "").toLowerCase();
              return event.categories!.any(
                (cat) => description.contains(cat.toLowerCase()),
              );
            }).toList();
      }

      // Sorting
      if (event.sortBy == "newest") {
        filtered.sort(
          (a, b) => DateTime.parse(
            b['createdAt'].toString(),
          ).compareTo(DateTime.parse(a['createdAt'].toString())),
        );
      } else if (event.sortBy == "oldest") {
        filtered.sort(
          (a, b) => DateTime.parse(
            a['createdAt'].toString(),
          ).compareTo(DateTime.parse(b['createdAt'].toString())),
        );
      } else if (event.sortBy == "highest") {
        filtered.sort(
          (a, b) => (b['data'].amount ?? 0).compareTo(a['data'].amount ?? 0),
        );
      } else if (event.sortBy == "lowest") {
        filtered.sort(
          (a, b) => (a['data'].amount ?? 0).compareTo(b['data'].amount ?? 0),
        );
      }

      emit(TransactionsState.getAllTransactionSuccess(transactions: filtered));
    } catch (e, stack) {
      log.e('Filter error: $e\n$stack');
      emit(const TransactionsState.failure());
    }
  }
}
