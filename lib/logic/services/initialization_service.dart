import 'package:montra/logic/blocs/budget_bloc/budget_bloc.dart';
import 'package:montra/logic/blocs/income_bloc/income_bloc.dart';
import 'package:montra/logic/database/database_helper.dart';

class InitializationService {
  final dbHelper = DatabaseHelper();

  Future<void> initialise() async {
    await clearAllNotifications();
    await initializeWallets();
    await getAllBudgets();
  }

  Future<void> clearAllNotifications() async {
    await dbHelper.clearAllNotifications();
  }

  Future<void> initializeWallets() async {
    IncomeBloc().add(IncomeEvent.getWallets());
  }

  Future<void> getAllBudgets() async {
    BudgetBloc().add(BudgetEvent.getAllBudgets());
  }
}
