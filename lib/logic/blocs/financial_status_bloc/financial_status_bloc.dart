import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/logic/database/database_helper.dart';

part 'financial_status_event.dart';
part 'financial_status_state.dart';
part 'financial_status_bloc.freezed.dart';

class FinancialStatusBloc
    extends Bloc<FinancialStatusEvent, FinancialStatusState> {
  FinancialStatusBloc() : super(FinancialStatusState.initial()) {
    on<LoadFinancialStatus>(_onLoadFinancialStatus);
  }

  // Fetch data and update the state when LoadFinancialStatus event is called
  Future<void> _onLoadFinancialStatus(
    LoadFinancialStatus event,
    Emitter<FinancialStatusState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FinancialStatus.loading));

      // Fetch biggest income source
      final biggestIncomeSource =
          await DatabaseHelper().getBiggestIncomeSource();

      // Fetch biggest expense source
      final biggestExpenseSource =
          await DatabaseHelper().getBiggestExpenseSource();

      // Fetch number of budgets exceeded this month
      final numberOfBudgetsExceeded =
          await DatabaseHelper().getNumberOfBudgetsExceededThisMonth();

      // Emit updated state with fetched data
      emit(
        state.copyWith(
          status: FinancialStatus.loaded,
          biggestIncomeSource: biggestIncomeSource,
          biggestExpenseSource: biggestExpenseSource,
          numberOfBudgetsExceeded: numberOfBudgetsExceeded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FinancialStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
