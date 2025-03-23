import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/bank/bank_api.dart';
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
      log.d('Get Bank Balance Response: $bankBalance');
      final walletBalance = await _walletApi.getBalance();
      log.d('Get Wallet Balance Response: $walletBalance');
      final totalBalance = bankBalance.balance + walletBalance.balance;
      log.d('Total Balance: $totalBalance');
      emit(AccountState.getAccountBalanceSuccess(balance: totalBalance));
      // final response = await _accountApi.getAccount();
      // log.d('Get Account Response: $response');
      // emit(AccountState.getAccountSuccess(account: response.account));
    } catch (e) {
      log.e('Error: $e');
      emit(AccountState.failure());
    }
  }
}
