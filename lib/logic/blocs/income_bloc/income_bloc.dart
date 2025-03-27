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
    on<_SetIncome>(_setIncome);
    on<_CreateIncome>(_createIncome);
    on<_GetWallets>(_getWallets);
  }

  final _incomeApi = IncomeApi(DioFactory().create());
  final _walletApi = WalletApi(DioFactory().create());

  Future<void> _getIncome(_GetIncome event, Emitter<IncomeState> emit) async {
    try {
      emit(IncomeState.inProgress());

      final dbHelper = DatabaseHelper();

      // Try fetching total income from the API
      try {
        final response = await _incomeApi.getIncome();
        log.d('Get Total Income Response: $response');

        // Store the total income in the local database
        await dbHelper.upsertAccountBalance(response.income.toDouble());

        emit(IncomeState.getIncomeSuccess(income: response.income));
      } catch (apiError) {
        log.e('API Error: $apiError');

        // Fallback to local database
        final localIncome = await dbHelper.getAccountBalance();
        if (localIncome != null) {
          emit(IncomeState.getIncomeSuccess(income: localIncome.toInt()));
        } else {
          throw Exception(
            'Failed to fetch total income from API and local database',
          );
        }
      }
    } catch (e) {
      log.e('Error: $e');
      emit(IncomeState.failure());
    }
  }

  Future<void> _getWallets(_GetWallets event, Emitter<IncomeState> emit) async {
    try {
      emit(IncomeState.inProgress());
      final response = await _walletApi.getAllWalletNames();
      log.d('Get Wallet Names: $response');
      emit(IncomeState.getWalletNamesSuccess(walletNames: response.wallets));
    } catch (e) {
      log.e('Error: $e');
      emit(IncomeState.failure());
    }
  }

  Future<void> _createIncome(
    _CreateIncome event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      emit(IncomeState.inProgress());

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

  Future<void> _setIncome(_SetIncome event, Emitter<IncomeState> emit) async {
    emit(IncomeState.inProgress());

    // final response = await _userApi.setIncome(
    //   amount: event.amount,
    //   source: event.source,
    //   description: event.description,
    // );

    emit(IncomeState.setIncomeSuccess());
  }
}
