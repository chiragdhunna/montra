part of 'income_bloc.dart';

@freezed
class IncomeState with _$IncomeState {
  const factory IncomeState.initial() = _Initial;
  const factory IncomeState.getIncomeSuccess({required int income}) =
      _GetIncomeSuccess;
  const factory IncomeState.getWalletNamesSuccess({
    required List<String> walletNames,
  }) = _GetWalletNamesSuccess;
  const factory IncomeState.setIncomeSuccess() = _SetIncomeSuccess;
  const factory IncomeState.createIncomeSuccess() = _CreateIncomeSuccess;
  const factory IncomeState.failure() = _Failure;
  const factory IncomeState.inProgress() = _InProgress;
}
