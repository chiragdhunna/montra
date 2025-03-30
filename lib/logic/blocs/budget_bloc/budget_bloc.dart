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
import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
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

    // Get the current year
    final now = DateTime.now();
    final year = now.year;

    // Format the month (ensure it's two digits)
    String formattedMonth = "${year}-${event.month.toString().padLeft(2, '0')}";

    log.w("Formatted month: $formattedMonth");

    final localBudgets = await dbHelper.getBudgetsByMonth(formattedMonth);

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
        // Sync pending deletions first
        final pendingDeletions = await dbHelper.getBudgetsPendingDeletion();
        for (final budget in pendingDeletions) {
          try {
            await _budgetApi.deleteBudget(
              DeleteBudgetModel(budgetId: budget['budget_id']),
            );
            await dbHelper.deleteBudget(
              budget['budget_id'],
            ); // Delete from DB after syncing
          } catch (e) {
            log.e('Failed to sync deletion: $e');
          }
        }

        // Sync unsynced budgets
        final unsyncedBudgets = await dbHelper.getUnSyncedBudgets();
        for (final budget in unsyncedBudgets) {
          if (budget['budget_id']!.startsWith('local_')) {
            // Create new budget on the server
            try {
              await _budgetApi.createBudget(
                CreateBudgetModel(
                  name: budget['name'],
                  totalBudget: budget['total_budget'],
                ),
              );
              await dbHelper.markBudgetAsSynced(budget['budget_id']);
            } catch (e) {
              log.e('Failed to sync new budget: $e');
            }
          } else {
            // Update existing budget on the server
            try {
              await _budgetApi.updateBudget(
                UpdateBudgetModel(
                  budgetId: budget['budget_id'],
                  name: budget['name'],
                  totalBudget: budget['total_budget'],
                  current: budget['current'],
                ),
              );
              await dbHelper.markBudgetAsSynced(budget['budget_id']);
            } catch (e) {
              log.e('Failed to sync updated budget: $e');
            }
          }
        }

        // Fetch all budgets from the server and update local DB
        final response = await _budgetApi.getAllBudgets();
        final budgetsData =
            response.budgets.map((b) {
              return {
                'budget_id': b.budgetId,
                'total_budget': b.totalBudget,
                'name': b.name,
                'user_id': b.userId,
                'current': b.current,
                'created_at': b.createdAt.toIso8601String(),
                'is_synced': 1,
                'pending_deletion': 0,
              };
            }).toList();

        // Replace the budgets in the local DB with the new server data
        await dbHelper.upsertBudgets(budgetsData);

        // Map the database results to a List<BudgetModel> before passing it to BudgetState
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
      } catch (e) {
        log.e('Error syncing budgets: $e');
        emit(BudgetState.failure());
      }
    } else {
      final localBudgets = await dbHelper.getAllBudgets();

      // Map the database results to a List<BudgetModel>
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

  Future<void> _createBudget(
    _CreateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    final dbHelper = DatabaseHelper();
    final isConnected = await NetworkHelper.checkNow();

    emit(BudgetState.inProgress());

    try {
      // Generate a temporary local ID for the budget
      final tempBudgetId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final user = await AuthenticationBloc().getAuthUser();

      final userId = user.userId;

      // Create local budget entry
      final budgetMap = {
        'budget_id': tempBudgetId,
        'total_budget': event.amount,
        'name': event.budgetName,
        'user_id': userId,
        'current': 0,
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': isConnected ? 1 : 0, // Mark as not synced if offline
      };

      await dbHelper.insertBudget(budgetMap);

      // If online, try to create on server as well
      if (isConnected) {
        try {
          final createBudget = CreateBudgetModel(
            name: event.budgetName,
            totalBudget: event.amount,
          );
          await _budgetApi.createBudget(createBudget);
          // Update local entry to mark as synced
          await dbHelper.markBudgetAsSynced(tempBudgetId);
        } catch (e) {
          log.e('API Error on create: $e');
          // Keep local changes, will sync later
        }
      }

      emit(BudgetState.createBudgetSuccess());
    } catch (e) {
      log.e('Error creating budget: $e');
      emit(BudgetState.failure());
    }
  }

  Future<void> _updateBudget(
    _UpdateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    final dbHelper = DatabaseHelper();
    final isConnected = await NetworkHelper.checkNow();

    emit(BudgetState.inProgress());

    // Get the existing budget from the local database
    final existingBudget = await dbHelper.getBudgetById(event.budgetId);

    if (existingBudget == null) {
      emit(BudgetState.failure());
      return;
    }

    // Create the updated budget map
    final updatedBudget = {
      'budget_id': event.budgetId,
      'name': event.budgetName,
      'total_budget': event.totalBudget,
      'current': event.current,
      // Set to unsynced if offline
      'is_synced': isConnected ? 1 : 0,
    };

    try {
      // Update the budget in the local database
      await dbHelper.updateBudget(updatedBudget);

      if (isConnected) {
        // If online, sync with the server
        await _budgetApi.updateBudget(
          UpdateBudgetModel(
            budgetId: event.budgetId,
            name: event.budgetName,
            totalBudget: event.totalBudget,
            current: event.current,
          ),
        );

        // After successful sync, mark as synced in the local DB
        await dbHelper.markBudgetAsSynced(event.budgetId);
      }

      emit(BudgetState.updateBudgetSuccess());
    } catch (e) {
      log.e('Error updating budget: $e');
      emit(BudgetState.failure());
    }
  }

  Future<void> _deleteBudget(
    _DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    final dbHelper = DatabaseHelper();
    final isConnected = await NetworkHelper.checkNow();

    emit(BudgetState.inProgress());

    try {
      // Delete from local DB first
      await dbHelper.deleteBudget(event.budgetId);

      // If budget ID starts with 'local_', it was never synced with server
      if (!event.budgetId.startsWith('local_') && isConnected) {
        try {
          final deleteBudget = DeleteBudgetModel(budgetId: event.budgetId);
          await _budgetApi.deleteBudget(deleteBudget);
        } catch (e) {
          log.e('API Error on delete: $e');
          // Mark for deletion when online
          await dbHelper.markBudgetForDeletion(event.budgetId);
        }
      }

      emit(BudgetState.deleteBudgetSuccess());
    } catch (e) {
      log.e('Error deleting budget: $e');
      emit(BudgetState.failure());
    }
  }
}
