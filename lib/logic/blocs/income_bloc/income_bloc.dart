import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/constants/income_source.dart';
import 'package:montra/logic/api/income/income_api.dart';
import 'package:montra/logic/dio_factory.dart';

part 'income_event.dart';
part 'income_state.dart';
part 'income_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  IncomeBloc() : super(_Initial()) {
    on<IncomeEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<_GetIncome>(_getIncome);
    on<_SetIncome>(_setIncome);
  }

  final _incomeApi = IncomeApi(DioFactory().create());

  Future<void> _getIncome(_GetIncome event, Emitter<IncomeState> emit) async {
    try {
      emit(IncomeState.inProgress());
      final response = await _incomeApi.getIncome();
      log.d('Get Income Response: $response');
      emit(IncomeState.getIncomeSuccess(income: response.income));
    } catch (e) {
      log.e('Error: $e');
      emit(IncomeState.failure());
    }
  }

  Future<void> _setIncome(_SetIncome event, Emitter<IncomeState> emit) async {
    emit(IncomeState.inProgress());

    // final response = await _userApi.setIncome(
    //   amount: event.amount,
    //   source: event.source,
    //   description: event.description,
    // );

    emit(IncomeState.setIncomeSuccess());
  }
}
