part of 'income_bloc.dart';

@freezed
class IncomeEvent with _$IncomeEvent {
  const factory IncomeEvent.started() = _Started;
  const factory IncomeEvent.getIncome() = _GetIncome;
  const factory IncomeEvent.setIncome({
    required int amount,
    required IncomeSource source,
    required String description,
  }) = _SetIncome;
}
