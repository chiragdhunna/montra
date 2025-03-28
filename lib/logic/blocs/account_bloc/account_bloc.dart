import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/bank/bank_api.dart';
import 'package:montra/logic/api/bank/models/bank_model.dart';
import 'package:montra/logic/api/bank/models/bank_name_model.dart';
import 'package:montra/logic/api/bank/models/bank_transaction_model.dart';
import 'package:montra/logic/api/bank/models/banks_model.dart';
import 'package:montra/logic/api/bank/models/create_bank_account_model.dart';
import 'package:montra/logic/api/bank/models/update_bank_model.dart';
import 'package:montra/logic/api/wallet/models/create_wallet_model.dart';
import 'package:montra/logic/api/wallet/models/update_wallet_model.dart';
import 'package:montra/logic/api/wallet/models/wallet_model.dart';
import 'package:montra/logic/api/wallet/models/wallet_name_model.dart';
import 'package:montra/logic/api/wallet/models/wallets_model.dart';
import 'package:montra/logic/api/wallet/wallet_api.dart';
import 'package:montra/logic/blocs/network_bloc/network_bloc.dart';
import 'package:montra/logic/blocs/network_bloc/network_helper.dart';
import 'package:montra/logic/database/database_helper.dart';
import 'package:montra/logic/dio_factory.dart';

part 'account_event.dart';
part 'account_state.dart';
part 'account_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(_Initial()) {
    on<_GetAccountBalance>(_getAccountBalance);
    on<_GetAccountDetails>(_getAccountDetails);
    on<_CreateAccount>(_createAccount);
    on<_GetAccountSourceDetails>(_getAccountSourceDetails);
    on<_UpdateWallet>(_updateWallet);
    on<_UpdateBankBalance>(_updateBankBalance);
  }

  final _bankApi = BankApi(DioFactory().create());
  final _walletApi = WalletApi(DioFactory().create());
  bool isConnected = false;

  Future<void> _getAccountBalance(
    _GetAccountBalance event,
    Emitter<AccountState> emit,
  ) async {
    try {
      emit(AccountState.inProgress());

      final dbHelper = DatabaseHelper();
      final isConnected = await NetworkHelper.checkNow();

      if (isConnected) {
        try {
          final bankBalance = await _bankApi.getBalance();
          final walletBalance = await _walletApi.getBalance();
          final totalBalance = bankBalance.balance + walletBalance.balance;

          await dbHelper.upsertAccountBalance(totalBalance.toDouble());

          emit(AccountState.getAccountBalanceSuccess(balance: totalBalance));
        } catch (apiError) {
          log.e('API Error: $apiError');

          // Try fallback to local DB even if API fails
          final localBalance = await dbHelper.getAccountBalance();

          if (localBalance != null) {
            log.w('Falling back to local DB due to API error');
            emit(
              AccountState.getAccountBalanceSuccess(
                balance: localBalance.toInt(),
              ),
            );
          } else {
            emit(
              AccountState.failure(
                error: 'API failed and no local data available.',
              ),
            );
          }
        }
      } else {
        final localBalance = await dbHelper.getAccountBalance();

        if (localBalance != null) {
          emit(
            AccountState.getAccountBalanceSuccess(
              balance: localBalance.toInt(),
            ),
          );
        } else {
          emit(
            AccountState.failure(
              error: 'No internet and no cached data available.',
            ),
          );
        }
      }
    } catch (e) {
      log.e('General Error: $e');
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
      final wallets = await _walletApi.getAllWalletAccounts();

      emit(
        AccountState.getAccountDetailsSuccess(
          balance: totalBalance,
          wallets: wallets,
          banks: banks,
        ),
      );
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

  Future<void> _updateWallet(
    _UpdateWallet event,
    Emitter<AccountState> emit,
  ) async {
    try {
      emit(AccountState.inProgress());
      final updateWallet = UpdateWalletModel(
        walletName: event.name,
        amount: event.amount,
        wallet_id: event.walletId,
      );
      await _walletApi.updateWalletById(updateWallet);
      emit(AccountState.updateWalletSuccess());
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

  Future<void> _updateBankBalance(
    _UpdateBankBalance event,
    Emitter<AccountState> emit,
  ) async {
    try {
      emit(AccountState.inProgress());

      final updateBankBalance = UpdateBankModel(
        amount: event.amount,
        accountNumber: event.accountNumber,
      );
      await _bankApi.updateBankBalance(updateBankBalance);

      emit(AccountState.updateBankBalanceSuccess());
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

  Future<void> _getAccountSourceDetails(
    _GetAccountSourceDetails event,
    Emitter<AccountState> emit,
  ) async {
    try {
      emit(AccountState.inProgress());

      if (event.bank != null) {
        final bankName = BankNameModel(bankName: event.bank!.name);
        final bankTransaction = await _bankApi.getAllBankTransactions(bankName);
        log.d('Transactions : $bankTransaction');
        emit(
          AccountState.getAccountSourceDetailsSuccess(
            transactions: bankTransaction,
          ),
        );
      } else {
        final walletName = WalletNameModel(walletName: event.wallet!.name);
        final walletTransaction = await _walletApi.getAllWalletTransactions(
          walletName,
        );
        log.d('Transactions : $walletTransaction');

        emit(
          AccountState.getAccountSourceDetailsSuccess(
            transactions: walletTransaction,
          ),
        );
      }
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

  Future<void> _createAccount(
    _CreateAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      emit(AccountState.inProgress());

      if (event.isWallet == false) {
        final createBankAccount = CreateBankAccountModel(
          bankName: event.name,
          amount: event.amount,
        );
        await _bankApi.createBankAccount(createBankAccount);
      } else {
        final createWallet = CreateWalletModel(
          name: event.name,
          amount: event.amount,
        );
        await _walletApi.createWallet(createWallet);
      }

      emit(AccountState.createAccountSuccess());
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
