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
    on<ExpenseEvent>((event, emit) {
      // TODO: implement event handler
    });
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

      final imageFile = event.attachment;
      String fileName = imageFile!.path.split('/').last;

      String? mimeType = lookupMimeType(imageFile.path) ?? "image/jpeg";
      List<String> mimeTypeData = mimeType.split('/');

      MultipartFile multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      );

      if (event.isBank != null && event.isBank!) {
        // Build FormData directly
        FormData formData = FormData.fromMap({
          "amount": event.amount.toString(),
          "source": event.source.name,
          "description": event.description,
          "file": multipartFile,
          "bank_name": event.bankName,
        });

        await _expenseApi.createExpense(
          formData,
        ); // Change this method to accept FormData
      } else if (event.isWallet != null && event.isWallet!) {
        FormData formData = FormData.fromMap({
          "amount": event.amount.toString(),
          "source": event.source.name,
          "description": event.description,
          "file": multipartFile,
          "wallet_name": event.walletName,
        });

        await _expenseApi.createExpense(
          formData,
        ); // Change this method to accept FormData
      } else {
        // Build FormData directly
        FormData formData = FormData.fromMap({
          "amount": event.amount.toString(),
          "source": event.source.name,
          "description": event.description,
          "file": multipartFile,
        });

        await _expenseApi.createExpense(
          formData,
        ); // Change this method to accept FormData
      }

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
        try {
          final response = await _expenseApi.getExpense();
          log.d('Get Total Expense Response: $response');

          final statsData = await _expenseApi.getExpenseStats();
          log.d('Get Expense Stats Response: $statsData');

          // Store the total expense in the local database
          await dbHelper.upsertAccountBalance(response.expense.toDouble());

          // Store expense stats in the local database
          await dbHelper.upsertExpenseStats(statsData.toJson());

          // Emit success state with API data
          emit(
            ExpenseState.getExpenseSuccess(
              expense: response.expense,
              expenseStats: statsData,
            ),
          );
        } catch (apiError) {
          log.e('API Error: $apiError');

          // Fallback to local DB
          final localExpense = await dbHelper.getAccountBalance();
          final localStatsJson = await dbHelper.getExpenseStats();

          if (localExpense != null) {
            log.w('Falling back to local DB due to API failure');
            emit(
              ExpenseState.getExpenseSuccess(
                expense: localExpense.toInt(),
                expenseStats:
                    localStatsJson != null
                        ? ExpenseStatsModel.fromJson(localStatsJson)
                        : null,
              ),
            );
          } else {
            emit(ExpenseState.failure());
          }
        }
      } else {
        // Offline fallback
        final localExpense = await dbHelper.getAccountBalance();
        final localStatsJson = await dbHelper.getExpenseStats();

        if (localExpense != null) {
          emit(
            ExpenseState.getExpenseSuccess(
              expense: localExpense.toInt(),
              expenseStats:
                  localStatsJson != null
                      ? ExpenseStatsModel.fromJson(localStatsJson)
                      : null,
            ),
          );
        } else {
          emit(ExpenseState.failure());
        }
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
    try {
      emit(ExpenseState.inProgress());
      final response = await _walletApi.getAllWalletNames();
      log.d('Get Wallet Names: $response');
      emit(ExpenseState.getWalletNamesSuccess(walletNames: response.wallets));
    } catch (e) {
      log.e('Error: $e');
      emit(ExpenseState.failure());
    }
  }

  Future<void> _setExpense(
    _SetExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseState.inProgress());

    // final response = await _userApi.setIncome(
    //   amount: event.amount,
    //   source: event.source,
    //   description: event.description,
    // );

    emit(ExpenseState.setExpenseSuccess());
  }
}
