part of 'account_bloc.dart';

@freezed
class AccountState with _$AccountState {
  const factory AccountState.initial() = _Initial;
  const factory AccountState.getAccountBalanceSuccess({required int balance}) =
      _GetAccountBalanceSuccess;
  const factory AccountState.getAccountDetailsSuccess({
    required int balance,
    required WalletsModel wallets,
    required BanksModel banks,
  }) = _GetAccountDetailsSuccess;

  const factory AccountState.getAccountSourceDetailsSuccess({
    BankTransactionModel? transactions,
  }) = _GetAccountSourceDetailsSuccess;

  const factory AccountState.failure({required String error}) = _Failure;
  const factory AccountState.createAccountSuccess() = _CreateAccountSuccess;
  const factory AccountState.updateWalletSuccess() = _UpdateWalletSuccess;
  const factory AccountState.updateBankBalanceSuccess() =
      _UpdateBankBalanceSuccess;
  const factory AccountState.inProgress() = _InProgress;
}
