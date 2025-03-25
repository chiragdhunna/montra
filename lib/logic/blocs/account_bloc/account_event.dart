part of 'account_bloc.dart';

@freezed
class AccountEvent with _$AccountEvent {
  const factory AccountEvent.started() = _Started;
  const factory AccountEvent.getAccountDetails() = _GetAccountDetails;
  const factory AccountEvent.getAccountBalance() = _GetAccountBalance;
  const factory AccountEvent.createBankAccount({
    required String bankName,
    required int amount,
  }) = _CreateBankAccount;
}
