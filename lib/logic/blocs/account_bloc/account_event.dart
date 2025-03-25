part of 'account_bloc.dart';

@freezed
class AccountEvent with _$AccountEvent {
  const factory AccountEvent.started() = _Started;
  const factory AccountEvent.getAccountDetails() = _GetAccountDetails;
  const factory AccountEvent.getAccountBalance() = _GetAccountBalance;
  const factory AccountEvent.createAccount({
    required String name,
    required int amount,
    required bool isWallet,
  }) = _CreateAccount;
}
