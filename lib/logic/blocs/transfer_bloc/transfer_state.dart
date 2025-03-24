part of 'transfer_bloc.dart';

@freezed
class TransferState with _$TransferState {
  const factory TransferState.initial() = _Initial;
  const factory TransferState.inProgress() = _InProgress;
  const factory TransferState.failure({required String error}) = _Failure;
  const factory TransferState.createTransferSuccess() = _CreateTransferSuccess;
}
