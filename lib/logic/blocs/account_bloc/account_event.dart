part of 'account_bloc.dart';

@freezed
class AccountEvent with _$AccountEvent {
  const factory AccountEvent.started() = _Started;
  const factory AccountEvent.getAccountDetails() = _GetAccountDetails;
  const factory AccountEvent.getAccountBalance() = _GetAccountBalance;
  const factory AccountEvent.updateWallet({
    required String name,
    required int amount,
    required String walletId,
  }) = _UpdateWallet;
  const factory AccountEvent.updateBankBalance({
    required int amount,
    required String accountNumber,
  }) = _UpdateBankBalance;
  const factory AccountEvent.getAccountSourceDetails({
    WalletModel? wallet,
    BankModel? bank,
  }) = _GetAccountSourceDetails;
  const factory AccountEvent.createAccount({
    required String name,
    required int amount,
    required bool isWallet,
  }) = _CreateAccount;
}
