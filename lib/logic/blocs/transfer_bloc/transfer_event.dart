part of 'transfer_bloc.dart';

@freezed
class TransferEvent with _$TransferEvent {
  const factory TransferEvent.started() = _Started;
  const factory TransferEvent.createTransfer({
    required int amount,
    required String from,
    required String to,
    required bool isExpense,
  }) = _CreateTransfer;
}
