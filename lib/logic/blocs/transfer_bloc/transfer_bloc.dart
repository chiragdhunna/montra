import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/transfer/models/create_transfer_model.dart';
import 'package:montra/logic/api/transfer/transfer_api.dart';
import 'package:montra/logic/blocs/network_bloc/network_helper.dart';
import 'package:montra/logic/database/database_helper.dart';
import 'package:montra/logic/dio_factory.dart';

part 'transfer_event.dart';
part 'transfer_state.dart';
part 'transfer_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc() : super(_Initial()) {
    on<TransferEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<_CreateTransfer>(_createTransfer);
  }

  final _transferApi = TransferApi(DioFactory().create());

  Future<void> _createTransfer(
    _CreateTransfer event,
    Emitter<TransferState> emit,
  ) async {
    try {
      emit(TransferState.inProgress());

      final dbHelper = DatabaseHelper();
      final isConnected = await NetworkHelper.checkNow();

      if (!isConnected) {
        await dbHelper.insertOfflineTransfer({
          "transfer_id": DateTime.now().millisecondsSinceEpoch.toString(),
          "amount": event.amount,
          "sender": event.from,
          "receiver": event.to,
          "is_expense": event.isExpense ? 1 : 0,
          "user_id": "mock_id",
          "created_at": DateTime.now().toIso8601String(),
        });

        emit(TransferState.createTransferSuccess());
        return;
      }

      final createTransferModel = CreateTransferModel(
        amount: event.amount,
        sender: event.from,
        receiver: event.to,
        isExpense: event.isExpense,
      );

      await _transferApi.createTransfer(createTransferModel);
      emit(TransferState.createTransferSuccess());
    } catch (e) {
      log.e('Error : $e');
      emit(TransferState.failure(error: e.toString()));
    }
  }
}
