import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/budget/budget_api.dart';
import 'package:montra/logic/api/budget/models/budget_model.dart';
import 'package:montra/logic/api/budget/models/budget_month_model.dart';
import 'package:montra/logic/api/budget/models/budgets_model.dart';
import 'package:montra/logic/api/budget/models/create_budget_model.dart';
import 'package:montra/logic/api/budget/models/delete_budget_model.dart';
import 'package:montra/logic/api/budget/models/update_budget_model.dart';
import 'package:montra/logic/blocs/network_bloc/network_helper.dart';
import 'package:montra/logic/database/database_helper.dart';
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
    on<_GetBudgetByMonth>(_getBudgetByMonth);
    on<_CreateBudget>(_createBudget);
    on<_UpdateBudget>(_updateBudget);
    on<_DeleteBudget>(_deleteBudget);
    on<_GetAllBudgets>(_getAllBudget);
  }

  final _budgetApi = BudgetApi(DioFactory().create());

  Future<void> _getBudgetByMonth(
    _GetBudgetByMonth event,
    Emitter<BudgetState> emit,
  ) async {
    final dbHelper = DatabaseHelper();

    emit(BudgetState.inProgress());

    final localBudgets = await dbHelper.getBudgetsByMonth(
      event.month.toString(),
    );

    emit(
      BudgetState.getBudgetByMonthSuccess(
        budgets: BudgetsModel(
          budgets:
              localBudgets
                  .map(
                    (b) => BudgetModel(
                      budgetId: b['budget_id'] as String,
                      totalBudget: b['total_budget'] as int,
                      name: b['name'] as String,
                      userId: b['user_id'] as String,
                      current: b['current'] as int,
                      createdAt: DateTime.parse(b['created_at'] as String),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Future<void> _getAllBudget(
    _GetAllBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    final dbHelper = DatabaseHelper();
    final isConnected = await NetworkHelper.checkNow();

    emit(BudgetState.inProgress());

    if (isConnected) {
      try {
        final response = await _budgetApi.getAllBudgets();

        // Save to local DB
        final budgetJsonList =
            response.budgets
                .map(
                  (b) => {
                    'budget_id': b.budgetId,
                    'total_budget': b.totalBudget,
                    'name': b.name,
                    'user_id': b.userId,
                    'current': b.current,
                    'created_at': b.createdAt.toIso8601String(),
                  },
                )
                .toList();

        await dbHelper.upsertBudgets(budgetJsonList);

        emit(BudgetState.getBudgetsSuccess(budgets: response));
      } catch (e) {
        log.e('API Error: $e');

        // fallback to local DB
        final localBudgets = await dbHelper.getAllBudgets();

        emit(
          BudgetState.getBudgetsSuccess(
            budgets: BudgetsModel(
              budgets:
                  localBudgets
                      .map(
                        (b) => BudgetModel(
                          budgetId: b['budget_id'] as String,
                          totalBudget: b['total_budget'] as int,
                          name: b['name'] as String,
                          userId: b['user_id'] as String,
                          current: b['current'] as int,
                          createdAt: DateTime.parse(b['created_at'] as String),
                        ),
                      )
                      .toList(),
            ),
          ),
        );
      }
    } else {
      final localBudgets = await dbHelper.getAllBudgets();

      if (localBudgets.isEmpty) {
        emit(BudgetState.failure());
      } else {
        emit(
          BudgetState.getBudgetsSuccess(
            budgets: BudgetsModel(
              budgets:
                  localBudgets
                      .map(
                        (b) => BudgetModel(
                          budgetId: b['budget_id'] as String,
                          totalBudget: b['total_budget'] as int,
                          name: b['name'] as String,
                          userId: b['user_id'] as String,
                          current: b['current'] as int,
                          createdAt: DateTime.parse(b['created_at'] as String),
                        ),
                      )
                      .toList(),
            ),
          ),
        );
      }
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
