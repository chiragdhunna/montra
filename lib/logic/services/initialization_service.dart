import 'package:montra/logic/blocs/budget_bloc/budget_bloc.dart';
import 'package:montra/logic/blocs/income_bloc/income_bloc.dart';

class InitializationService {
  Future<void> initialise() async {
    await initializeWallets();
    await getAllBudgets();
  }

  Future<void> initializeWallets() async {
    IncomeBloc().add(IncomeEvent.getWallets());
  }

  Future<void> getAllBudgets() async {
    BudgetBloc().add(BudgetEvent.getAllBudgets());
  }
}
