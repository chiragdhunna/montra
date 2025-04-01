import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/logic/database/database_helper.dart'; // Make sure the DatabaseHelper is imported

part 'financial_report_event.dart';
part 'financial_report_state.dart';
part 'financial_report_bloc.freezed.dart';

class FinancialReportBloc
    extends Bloc<FinancialReportEvent, FinancialReportState> {
  FinancialReportBloc() : super(const _Initial()) {
    on<_LoadFinancialReport>(_onLoadFinancialReport);
    on<_UpdateTimeFilter>(_onUpdateTimeFilter);
    on<_UpdateTransactionType>(_onUpdateTransactionType);
    on<_UpdateCategory>(_onUpdateCategory);
    on<_ToggleGraphView>(_onToggleGraphView);
  }

  Future<void> _onLoadFinancialReport(
    _LoadFinancialReport event,
    Emitter<FinancialReportState> emit,
  ) async {
    try {
      emit(const FinancialReportState.loading());

      // Load data from database
      final incomeBreakdown =
          await DatabaseHelper().getIncomeBreakdownBySource();
      final expenseBreakdown =
          await DatabaseHelper().getExpenseBreakdownBySource();
      final financeStats = await DatabaseHelper().getFinancialStatistics(
        months: 3,
      ); // You can adjust months based on the time filter

      final totalIncome = financeStats['total_income'] as int;
      final totalExpense = financeStats['total_expense'] as int;
      final totalBalance = totalIncome - totalExpense;

      emit(
        FinancialReportState.loaded(
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          totalBalance: totalBalance,
          incomeBreakdown: incomeBreakdown,
          expenseBreakdown: expenseBreakdown,
          financeStats: financeStats,
        ),
      );
    } catch (e) {
      emit(FinancialReportState.failure(e.toString()));
    }
  }

  Future<void> _onUpdateTimeFilter(
    _UpdateTimeFilter event,
    Emitter<FinancialReportState> emit,
  ) async {
    if (state is _Loaded) {
      final currentState = state as _Loaded;

      // Adjust the financial statistics based on the selected time filter
      final financeStats = await DatabaseHelper().getFinancialStatistics(
        months:
            event.filter == "Week"
                ? 1
                : event.filter == "Month"
                ? 3
                : 12,
      );

      final totalIncome = financeStats['total_income'] as int;
      final totalExpense = financeStats['total_expense'] as int;
      final totalBalance = totalIncome - totalExpense;

      emit(
        FinancialReportState.loaded(
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          totalBalance: totalBalance,
          incomeBreakdown: currentState.incomeBreakdown,
          expenseBreakdown: currentState.expenseBreakdown,
          financeStats: financeStats,
        ),
      );
    }
  }

  Future<void> _onUpdateTransactionType(
    _UpdateTransactionType event,
    Emitter<FinancialReportState> emit,
  ) async {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      // You can implement any logic here for updating transaction types if needed
      emit(
        FinancialReportState.loaded(
          totalIncome: currentState.totalIncome,
          totalExpense: currentState.totalExpense,
          totalBalance: currentState.totalBalance,
          incomeBreakdown: currentState.incomeBreakdown,
          expenseBreakdown: currentState.expenseBreakdown,
          financeStats: currentState.financeStats,
        ),
      );
    }
  }

  Future<void> _onUpdateCategory(
    _UpdateCategory event,
    Emitter<FinancialReportState> emit,
  ) async {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      // Handle updating the category (e.g., changing categories for income or expense)
      emit(
        FinancialReportState.loaded(
          totalIncome: currentState.totalIncome,
          totalExpense: currentState.totalExpense,
          totalBalance: currentState.totalBalance,
          incomeBreakdown: currentState.incomeBreakdown,
          expenseBreakdown: currentState.expenseBreakdown,
          financeStats: currentState.financeStats,
        ),
      );
    }
  }

  void _onToggleGraphView(
    _ToggleGraphView event,
    Emitter<FinancialReportState> emit,
  ) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      // Toggle graph view (between line chart and pie chart)
      emit(
        FinancialReportState.loaded(
          totalIncome: currentState.totalIncome,
          totalExpense: currentState.totalExpense,
          totalBalance: currentState.totalBalance,
          incomeBreakdown: currentState.incomeBreakdown,
          expenseBreakdown: currentState.expenseBreakdown,
          financeStats: currentState.financeStats,
        ),
      );
    }
  }
}
