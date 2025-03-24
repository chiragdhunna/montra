import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/constants/income_source.dart';
import 'package:montra/logic/api/expense/expense_api.dart';
import 'package:montra/logic/api/expense/models/expense_stats_model.dart';
import 'package:montra/logic/dio_factory.dart';

part 'expense_event.dart';
part 'expense_state.dart';
part 'expense_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(_Initial()) {
    on<ExpenseEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<_GetExpense>(_getExpense);
    on<_SetExpense>(_setExpense);
  }

  final _expenseApi = ExpenseApi(DioFactory().create());

  Future<void> _getExpense(
    _GetExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseState.inProgress());
      final response = await _expenseApi.getExpense();
      log.d('Get Income Response: $response');
      final statsData = await _expenseApi.getExpenseStats();
      log.d('Get Income Response: $statsData');
      emit(
        ExpenseState.getExpenseSuccess(
          expense: response.expense,
          expenseStats: statsData,
        ),
      );
    } catch (e) {
      log.e('Error: $e');
      emit(ExpenseState.failure());
    }
  }

  Future<void> _setExpense(
    _SetExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseState.inProgress());

    // final response = await _userApi.setIncome(
    //   amount: event.amount,
    //   source: event.source,
    //   description: event.description,
    // );

    emit(ExpenseState.setExpenseSuccess());
  }
}
