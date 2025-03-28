import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:montra/constants/income_source.dart';
import 'package:montra/logic/api/income/income_api.dart';
import 'package:montra/logic/api/wallet/wallet_api.dart';
import 'package:montra/logic/blocs/network_bloc/network_helper.dart';
import 'package:montra/logic/database/database_helper.dart';
import 'package:montra/logic/dio_factory.dart';

part 'income_event.dart';
part 'income_state.dart';
part 'income_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  IncomeBloc() : super(_Initial()) {
    on<IncomeEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<_GetIncome>(_getIncome);
    on<_CreateIncome>(_createIncome);
    on<_GetWallets>(_getWallets);
  }

  final _incomeApi = IncomeApi(DioFactory().create());
  final _walletApi = WalletApi(DioFactory().create());

  Future<void> _getIncome(_GetIncome event, Emitter<IncomeState> emit) async {
    try {
      emit(IncomeState.inProgress());

      final dbHelper = DatabaseHelper();
      final isConnected = await NetworkHelper.checkNow();

      if (isConnected) {
        final pending = await dbHelper.getOfflineIncomes();

        for (var income in pending) {
          try {
            final filePath = income["attachment"] ?? '';
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
              "amount": income["amount"].toString(),
              "source": income["source"],
              "description": income["description"],
              if (file != null) "file": file,
              if (income["bank_name"] != null) "bank_name": income["bank_name"],
              if (income["wallet_name"] != null)
                "wallet_name": income["wallet_name"],
            });

            await _incomeApi.createIncome(formData);
          } catch (e) {
            log.e("⛔ Failed to sync income: ${income["income_id"]}\nError: $e");
          }
        }

        await dbHelper.clearOfflineIncomes();

        final response = await _incomeApi.getIncome();
        await dbHelper.upsertAccountBalance(response.income.toDouble());

        emit(IncomeState.getIncomeSuccess(income: response.income));
      } else {
        final localIncome = await dbHelper.getAccountBalance();
        final offline = await dbHelper.getOfflineIncomes();
        final offlineTotal = offline.fold<int>(
          0,
          (sum, e) => sum + (e['amount'] as int),
        );

        log.w(
          'localIncome : $localIncome + offline : $offline + offlineTotal : $offlineTotal',
        );

        emit(
          IncomeState.getIncomeSuccess(
            income: (localIncome ?? 0).toInt() + offlineTotal,
          ),
        );
      }
    } catch (e) {
      log.e('Unexpected Error: $e');
      emit(IncomeState.failure());
    }
  }

  Future<void> _getWallets(_GetWallets event, Emitter<IncomeState> emit) async {
    final dbHelper = DatabaseHelper();

    try {
      emit(IncomeState.inProgress());

      final isConnected = await NetworkHelper.checkNow();

      if (isConnected) {
        try {
          final response = await _walletApi.getAllWalletNames();
          log.d('Get Wallet Names: $response');

          final walletNames = response.wallets;

          // Store to DB
          await dbHelper.upsertWalletNames(walletNames);

          emit(IncomeState.getWalletNamesSuccess(walletNames: walletNames));
        } catch (apiError) {
          log.e('API Error: $apiError');

          // Fallback to local DB
          final localWalletNames = await dbHelper.getWalletNames();
          if (localWalletNames.isNotEmpty) {
            log.w('Using cached wallet names due to API error');
            emit(
              IncomeState.getWalletNamesSuccess(walletNames: localWalletNames),
            );
          } else {
            emit(IncomeState.failure());
          }
        }
      } else {
        // Offline fallback
        final localWalletNames = await dbHelper.getWalletNames();
        if (localWalletNames.isNotEmpty) {
          emit(
            IncomeState.getWalletNamesSuccess(walletNames: localWalletNames),
          );
        } else {
          emit(IncomeState.failure());
        }
      }
    } catch (e) {
      log.e('Unexpected Error: $e');
      emit(IncomeState.failure());
    }
  }

  Future<void> _createIncome(
    _CreateIncome event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      emit(IncomeState.inProgress());

      final dbHelper = DatabaseHelper();
      final isConnected = await NetworkHelper.checkNow();

      if (!isConnected) {
        await dbHelper.insertOfflineIncome({
          "income_id": DateTime.now().millisecondsSinceEpoch.toString(),
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

        emit(IncomeState.createIncomeSuccess());
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

      if (event.isBank != null && event.isBank!) {
        // Build FormData directly
        FormData formData = FormData.fromMap({
          "amount": event.amount.toString(),
          "source": event.source.name,
          "description": event.description,
          "file": multipartFile,
          "bank_name": event.bankName,
        });

        await _incomeApi.createIncome(
          formData,
        ); // Change this method to accept FormData
      } else if (event.isWallet != null && event.isWallet!) {
        // Build FormData directly
        FormData formData = FormData.fromMap({
          "amount": event.amount.toString(),
          "source": event.source.name,
          "description": event.description,
          "file": multipartFile,
          "wallet_name": event.walletName,
        });

        await _incomeApi.createIncome(
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

        await _incomeApi.createIncome(
          formData,
        ); // Change this method to accept FormData
      }

      emit(IncomeState.createIncomeSuccess());
    } catch (e) {
      log.e('Error: $e');
      emit(IncomeState.failure());
    }
  }
}
