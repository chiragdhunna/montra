import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/bank/bank_api.dart';
import 'package:montra/logic/api/bank/models/bank_model.dart';
import 'package:montra/logic/api/bank/models/banks_model.dart';
import 'package:montra/logic/api/bank/models/create_bank_account_model.dart';
import 'package:montra/logic/api/wallet/models/wallet_model.dart';
import 'package:montra/logic/api/wallet/models/wallets_model.dart';
import 'package:montra/logic/api/wallet/wallet_api.dart';
import 'package:montra/logic/dio_factory.dart';

part 'account_event.dart';
part 'account_state.dart';
part 'account_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(_Initial()) {
    on<AccountEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<_GetAccountBalance>(_getAccountBalance);
    on<_GetAccountDetails>(_getAccountDetails);
    on<_CreateBankAccount>(_createBankAccount);
  }

  final _bankApi = BankApi(DioFactory().create());
  final _walletApi = WalletApi(DioFactory().create());

  Future<void> _getAccountBalance(
    _GetAccountBalance event,
    Emitter<AccountState> emit,
  ) async {
    try {
      emit(AccountState.inProgress());
      final bankBalance = await _bankApi.getBalance();
      log.w('Get Bank Balance Response: $bankBalance');
      final walletBalance = await _walletApi.getBalance();
      log.w('Get Wallet Balance Response: $walletBalance');
      final totalBalance = bankBalance.balance + walletBalance.balance;
      log.w('Total Balance: $totalBalance');
      emit(AccountState.getAccountBalanceSuccess(balance: totalBalance));
      // final response = await _accountApi.getAccount();
      // log.d('Get Account Response: $response');
      // emit(AccountState.getAccountSuccess(account: response.account));
    } catch (e) {
      log.e('Error: $e');
      emit(AccountState.failure(error: e.toString()));
    }
  }

  Future<void> _getAccountDetails(
    _GetAccountDetails event,
    Emitter<AccountState> emit,
  ) async {
    try {
      emit(AccountState.inProgress());
      final bankBalance = await _bankApi.getBalance();
      final walletBalance = await _walletApi.getBalance();
      final totalBalance = bankBalance.balance + walletBalance.balance;

      final banks = await _bankApi.getAllBankAccounts();
      final wallets = await _walletApi.getAllBankAccounts();

      emit(
        AccountState.getAccountDetailsSuccess(
          balance: totalBalance,
          wallets: wallets,
          banks: banks,
        ),
      );
      // final response = await _accountApi.getAccount();
      // log.d('Get Account Response: $response');
      // emit(AccountState.getAccountSuccess(account: response.account));
    } catch (e) {
      log.e('Error: $e');
      if (e is DioException) {
        log.e('Error Message ${e.message!}');
        emit(AccountState.failure(error: e.message!));
      } else {
        emit(AccountState.failure(error: e.toString()));
      }
    }
  }

  Future<void> _createBankAccount(
    _CreateBankAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      emit(AccountState.inProgress());

      final createBankAccount = CreateBankAccountModel(
        bankName: event.bankName,
        amount: event.amount,
      );
      await _bankApi.createBankAccount(createBankAccount);

      emit(AccountState.createBankAccountSuccess());
    } catch (e) {
      log.e('Error: $e');
      if (e is DioException) {
        log.e('Error Message ${e.response?.data?['message']}');
        emit(AccountState.failure(error: e.response?.data?['message']));
      } else {
        emit(AccountState.failure(error: e.toString()));
      }
    }
  }
}
