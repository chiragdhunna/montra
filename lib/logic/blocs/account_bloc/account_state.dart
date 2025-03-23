part of 'account_bloc.dart';

@freezed
class AccountState with _$AccountState {
  const factory AccountState.initial() = _Initial;
  const factory AccountState.getAccountBalanceSuccess({required int balance}) =
      _GetAccountBalanceSuccess;
  const factory AccountState.failure() = _Failure;
  const factory AccountState.inProgress() = _InProgress;
}
