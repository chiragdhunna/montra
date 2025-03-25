import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/budget/budget_api.dart';
import 'package:montra/logic/api/budget/models/budget_month_model.dart';
import 'package:montra/logic/api/budget/models/budgets_model.dart';
import 'package:montra/logic/api/budget/models/create_budget_model.dart';
import 'package:montra/logic/dio_factory.dart';

part 'budget_event.dart';
part 'budget_state.dart';
part 'budget_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc() : super(_Initial()) {
    on<BudgetEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<_GetBudgetByMonth>(_getBudgetByMonthSuccess);
    on<_CreateBudget>(_createBudget);
  }

  final _budgetApi = BudgetApi(DioFactory().create());

  Future<void> _getBudgetByMonthSuccess(
    _GetBudgetByMonth event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(BudgetState.inProgress());
      final month = BudgetMonthModel(month: event.month.toString());
      final response = await _budgetApi.getbymonth(month);
      log.d('Budget for current Month : $response');
      emit(BudgetState.getBudgetByMonthSuccess(budgets: response));
    } catch (e) {
      log.e('Error : $e');
      emit(BudgetState.failure());
    }
  }

  Future<void> _createBudget(
    _CreateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(BudgetState.inProgress());
      final createBudget = CreateBudgetModel(
        name: event.budgetName,
        totalBudget: event.amount,
      );
      await _budgetApi.createBudget(createBudget);
      emit(BudgetState.createBudgetSuccess());
    } catch (e) {
      log.e('Error : $e');
      emit(BudgetState.failure());
    }
  }
}
