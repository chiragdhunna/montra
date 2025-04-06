import 'dart:async';

import 'package:montra/logic/blocs/account_bloc/account_bloc.dart';
import 'package:montra/logic/blocs/budget_bloc/budget_bloc.dart';
import 'package:montra/logic/blocs/income_bloc/income_bloc.dart';
import 'package:montra/logic/database/database_helper.dart';

class InitializationService {
  final dbHelper = DatabaseHelper();

  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;

  Future<void> initialise() async {
    const totalSteps = 4;
    int completedSteps = 0;

    await clearAllNotifications();
    _progressController.add(++completedSteps / totalSteps);

    await initializeWallets();
    _progressController.add(++completedSteps / totalSteps);

    await getAllBudgets();
    _progressController.add(++completedSteps / totalSteps);

    await syncAccount();
    _progressController.add(++completedSteps / totalSteps);

    await _progressController.close();
  }

  Future<void> clearAllNotifications() async {
    await dbHelper.clearAllNotifications();
  }

  Future<void> initializeWallets() async {
    IncomeBloc().add(IncomeEvent.getWallets());
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // simulate wait for async behavior
  }

  Future<void> getAllBudgets() async {
    BudgetBloc().add(BudgetEvent.getAllBudgets());
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> syncAccount() async {
    await AccountBloc().syncData();
  }
}
