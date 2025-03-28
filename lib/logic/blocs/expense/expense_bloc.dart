import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:montra/constants/expense_type.dart';
import 'package:montra/constants/income_source.dart';
import 'package:montra/logic/api/expense/expense_api.dart';
import 'package:montra/logic/api/expense/models/expense_model.dart';
import 'package:montra/logic/api/expense/models/expense_stats_model.dart';
import 'package:montra/logic/api/wallet/wallet_api.dart';
import 'package:montra/logic/blocs/network_bloc/network_helper.dart';
import 'package:montra/logic/database/database_helper.dart';
import 'package:montra/logic/dio_factory.dart';

part 'expense_event.dart';
part 'expense_state.dart';
part 'expense_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(_Initial()) {
    on<ExpenseEvent>((event, emit) {});
    on<_GetExpense>(_getExpense);
    on<_SetExpense>(_setExpense);
    on<_CreateExpense>(_createExpense);
    on<_GetWallets>(_getWallets);
  }

  final _expenseApi = ExpenseApi(DioFactory().create());
  final _walletApi = WalletApi(DioFactory().create());

  Future<void> _createExpense(
    _CreateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseState.inProgress());

      final dbHelper = DatabaseHelper();
      final isConnected = await NetworkHelper.checkNow();

      if (!isConnected) {
        await dbHelper.insertOfflineExpense({
          "expense_id": DateTime.now().millisecondsSinceEpoch.toString(),
          "amount": event.amount,
          "user_id": "mock_id",
          "source": event.source.name,
          "attachment": event.attachment?.path ?? '',
          "description": event.description,
          "created_at": DateTime.now().toIso8601String(),
          "bank_name": event.bankName,
          "wallet_name": event.walletName,
        });

        final current = await dbHelper.getAccountBalance() ?? 0;
        await dbHelper.upsertAccountBalance(current + event.amount);

        emit(ExpenseState.createExpenseSuccess());
        return;
      }

      final imageFile = event.attachment;
      String fileName = imageFile!.path.split('/').last;

      String? mimeType = lookupMimeType(imageFile.path) ?? "image/jpeg";
      List<String> mimeTypeData = mimeType.split('/');

      MultipartFile multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      );

      FormData formData = FormData.fromMap({
        "amount": event.amount.toString(),
        "source": event.source.name,
        "description": event.description,
        "file": multipartFile,
        if (event.isBank == true) "bank_name": event.bankName,
        if (event.isWallet == true) "wallet_name": event.walletName,
      });

      await _expenseApi.createExpense(formData);
      emit(ExpenseState.createExpenseSuccess());
    } catch (e) {
      log.e('Error: $e');
      emit(ExpenseState.failure());
    }
  }

  Future<void> _getExpense(
    _GetExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseState.inProgress());

      final dbHelper = DatabaseHelper();
      final isConnected = await NetworkHelper.checkNow();

      if (isConnected) {
        final pending = await dbHelper.getOfflineExpenses();

        for (var expense in pending) {
          try {
            final filePath = expense["attachment"] ?? '';
            MultipartFile? file;
            if (filePath.isNotEmpty && File(filePath).existsSync()) {
              final mimeType = lookupMimeType(filePath) ?? "image/jpeg";
              final mimeSplit = mimeType.split('/');

              file = await MultipartFile.fromFile(
                filePath,
                filename: filePath.split('/').last,
                contentType: MediaType(mimeSplit[0], mimeSplit[1]),
              );
            }

            final formData = FormData.fromMap({
              "amount": expense["amount"].toString(),
              "source": expense["source"],
              "description": expense["description"],
              if (file != null) "file": file,
              if (expense["bank_name"] != null)
                "bank_name": expense["bank_name"],
              if (expense["wallet_name"] != null)
                "wallet_name": expense["wallet_name"],
            });

            await _expenseApi.createExpense(formData);
          } catch (e) {
            log.e(
              "⛔ Failed to sync expense: ${expense["expense_id"]}\nError: $e",
            );
          }
        }

        await dbHelper.clearOfflineExpenses();

        final response = await _expenseApi.getExpense();
        final statsData = await _expenseApi.getExpenseStats();

        await dbHelper.upsertAccountBalance(response.expense.toDouble());
        await dbHelper.upsertExpenseStats(statsData.toJson());

        emit(
          ExpenseState.getExpenseSuccess(
            expense: response.expense,
            expenseStats: statsData,
          ),
        );
      } else {
        final localExpense = await dbHelper.getAccountBalance();
        final localStatsJson = await dbHelper.getExpenseStats();
        final offline = await dbHelper.getOfflineExpenses();
        final offlineTotal = offline.fold<int>(
          0,
          (sum, e) => sum + (e['amount'] as int),
        );

        emit(
          ExpenseState.getExpenseSuccess(
            expense: (localExpense ?? 0).toInt() + offlineTotal,
            expenseStats:
                localStatsJson != null
                    ? ExpenseStatsModel.fromJson(localStatsJson)
                    : null,
          ),
        );
      }
    } catch (e) {
      log.e('Unexpected Error: $e');
      emit(ExpenseState.failure());
    }
  }

  Future<void> _getWallets(
    _GetWallets event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseState.inProgress());

    final isConnected = await NetworkHelper.checkNow();
    final dbHelper = DatabaseHelper();

    if (isConnected) {
      try {
        final response = await _walletApi.getAllWalletNames();
        log.d('Get Wallet Names: $response');

        final walletNames = response.wallets;

        // Store to DB
        await dbHelper.upsertWalletNames(walletNames);

        emit(ExpenseState.getWalletNamesSuccess(walletNames: walletNames));
      } catch (apiError) {
        log.e('API Error: $apiError');

        // Fallback to local DB
        final localWalletNames = await dbHelper.getWalletNames();
        if (localWalletNames.isNotEmpty) {
          log.w('Using cached wallet names due to API error');
          emit(
            ExpenseState.getWalletNamesSuccess(walletNames: localWalletNames),
          );
        } else {
          emit(ExpenseState.failure());
        }
      }
    } else {
      // Offline fallback
      final localWalletNames = await dbHelper.getWalletNames();
      if (localWalletNames.isNotEmpty) {
        emit(ExpenseState.getWalletNamesSuccess(walletNames: localWalletNames));
      } else {
        emit(ExpenseState.failure());
      }
    }
  }

  Future<void> _setExpense(
    _SetExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseState.inProgress());
    emit(ExpenseState.setExpenseSuccess());
  }
}
