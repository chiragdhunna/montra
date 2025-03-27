import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/constants/models/transactions_model.dart';
import 'package:montra/logic/api/expense/expense_api.dart';
import 'package:montra/logic/api/expense/models/expense_model.dart';
import 'package:montra/logic/api/expense/models/expenses_model.dart';
import 'package:montra/logic/api/income/income_api.dart';
import 'package:montra/logic/api/income/models/income_model.dart';
import 'package:montra/logic/api/income/models/incomes_model.dart';
import 'package:montra/logic/api/transfer/models/transfer_model.dart';
import 'package:montra/logic/api/transfer/models/transfers_model.dart';
import 'package:montra/logic/api/transfer/transfer_api.dart';
import 'package:montra/logic/database/database_helper.dart';
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

  List<Map<String, dynamic>> preprocessTransfers(
    List<Map<String, dynamic>> dbTransfers,
  ) {
    return dbTransfers.map((e) {
      return {
        'transfer_id': e['transfer_id'] ?? '', // Default to empty string
        'amount': e['amount'] ?? 0, // Default to 0 if null
        'sender': e['sender'] ?? '',
        'receiver': e['receiver'] ?? '',
        'user_id': e['user_id'] ?? '',
        'is_expense': (e['is_expense'] as int?) == 1, // Convert int to bool
        'created_at':
            e['created_at'] ??
            DateTime.now().toIso8601String(), // Default to current time
      };
    }).toList();
  }

  List<Map<String, dynamic>> preprocessIncomes(
    List<Map<String, dynamic>> dbIncomes,
  ) {
    return dbIncomes.map((e) {
      return {
        'income_id': e['income_id'] ?? '', // Default to empty string
        'amount': e['amount'] ?? 0, // Default to 0 if null
        'user_id': e['user_id'] ?? '',
        'source': e['source'] ?? 'unknown', // Default to 'unknown'
        'attachment': e['attachment'],
        'description': e['description'] ?? '',
        'created_at':
            e['created_at'] ??
            DateTime.now().toIso8601String(), // Default to current time
        'bank_name': e['bank_name'],
        'wallet_name': e['wallet_name'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> preprocessExpenses(
    List<Map<String, dynamic>> dbExpenses,
  ) {
    return dbExpenses.map((e) {
      return {
        'expense_id': e['expense_id'] ?? '', // Default to empty string
        'amount': e['amount'] ?? 0, // Default to 0 if null
        'user_id': e['user_id'] ?? '',
        'source': e['source'] ?? 'unknown', // Default to 'unknown'
        'attachment': e['attachment'],
        'description': e['description'] ?? '',
        'created_at':
            e['created_at'] ??
            DateTime.now().toIso8601String(), // Default to current time
        'bank_name': e['bank_name'],
        'wallet_name': e['wallet_name'],
      };
    }).toList();
  }

  Future<void> _getAllTransactions(
    _GetAllTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      emit(TransactionsState.inProgress());

      // Fetch data from the database
      final dbHelper = DatabaseHelper();
      final dbExpenses = await dbHelper.getExpenses();
      final dbIncomes = await dbHelper.getIncome();
      final dbTransfers = await dbHelper.getTransfers();

      if (dbExpenses.isNotEmpty &&
          dbIncomes.isNotEmpty &&
          dbTransfers.isNotEmpty) {
        // Preprocess database data
        final dbTransfers = await dbHelper.getTransfers();
        final processedTransfers = preprocessTransfers(dbTransfers);

        final transactions = TransactionsModels(
          transfer: TransfersModel(
            transfers:
                processedTransfers
                    .map((e) => TransferModel.fromJson(e))
                    .toList(),
          ),
          incomes: IncomesModel(
            incomes: dbIncomes.map((e) => IncomeModel.fromJson(e)).toList(),
          ),
          expenses: ExpensesModel(
            expenses: dbExpenses.map((e) => ExpenseModel.fromJson(e)).toList(),
          ),
        );

        // Sort transactions
        final sortedTransactions = getSortedTransactions(transactions);

        emit(
          TransactionsState.getAllTransactionSuccess(
            transactions: sortedTransactions,
          ),
        );
      } else {
        // Fetch data from APIs if offline data is not available
        final expenses = await _expenseApi.getAllExpenses();
        final incomes = await _incomeApi.getAllIncomes();
        final transfers = await _transferApi.getAllTransfers();

        // Save fetched data to the database
        await dbHelper.upsertExpenses(
          expenses.expenses.map((e) => e.toJson()).toList(),
        );
        await dbHelper.upsertIncome(
          incomes.incomes.map((e) => e.toJson()).toList(),
        );
        await dbHelper.upsertTransfers(
          transfers.transfers.map((e) => e.toJson()).toList(),
        );

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
      }
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

      // Fetch data from the database
      final dbHelper = DatabaseHelper();
      final dbExpenses = await dbHelper.getExpenses();
      final dbIncomes = await dbHelper.getIncome();
      final dbTransfers = await dbHelper.getTransfers();

      // Preprocess database data
      final processedExpenses = preprocessExpenses(dbExpenses);
      final processedIncomes = preprocessIncomes(dbIncomes);
      final processedTransfers = preprocessTransfers(dbTransfers);

      final all = <Map<String, dynamic>>[];

      // Merge and label data
      for (final e in processedExpenses) {
        all.add({
          'data': ExpenseModel.fromJson(e),
          'type': 'expense',
          'createdAt': e['created_at'],
        });
      }
      for (final i in processedIncomes) {
        all.add({
          'data': IncomeModel.fromJson(i),
          'type': 'income',
          'createdAt': i['created_at'],
        });
      }
      for (final t in processedTransfers) {
        all.add({
          'data': TransferModel.fromJson(t),
          'type': 'transfer',
          'createdAt': t['created_at'],
        });
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
