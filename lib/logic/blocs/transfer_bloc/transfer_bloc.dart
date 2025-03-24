import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/transfer/models/create_transfer_model.dart';
import 'package:montra/logic/api/transfer/transfer_api.dart';
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
