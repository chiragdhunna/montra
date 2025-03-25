import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/budget/budget_api.dart';
import 'package:montra/logic/api/budget/models/budget_month_model.dart';
import 'package:montra/logic/api/budget/models/budgets_model.dart';
import 'package:montra/logic/api/budget/models/create_budget_model.dart';
import 'package:montra/logic/api/budget/models/delete_budget_model.dart';
import 'package:montra/logic/api/budget/models/update_budget_model.dart';
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
    on<_UpdateBudget>(_updateBudget);
    on<_DeleteBudget>(_deleteBudget);
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

  Future<void> _updateBudget(
    _UpdateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(BudgetState.inProgress());
      final updateBudget = UpdateBudgetModel(
        name: event.budgetName,
        totalBudget: event.totalBudget,
        budgetId: event.budgetId,
        current: event.current,
      );
      await _budgetApi.updateBudget(updateBudget);
      emit(BudgetState.updateBudgetSuccess());
    } catch (e) {
      log.e('Error : $e');
      emit(BudgetState.failure());
    }
  }

  Future<void> _deleteBudget(
    _DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(BudgetState.inProgress());
      final deleteBudget = DeleteBudgetModel(budgetId: event.budgetId);
      await _budgetApi.deleteBudget(deleteBudget);
      emit(BudgetState.deleteBudgetSuccess());
    } catch (e) {
      log.e('Error : $e');
      emit(BudgetState.failure());
    }
  }
}
