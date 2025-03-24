import 'package:dio/dio.dart';
import 'package:montra/logic/api/expense/models/expense_stats_model.dart';
import 'package:montra/logic/api/expense/models/expenses_model.dart';
import 'package:montra/logic/api/expense/models/total_expense_model.dart';
import 'package:retrofit/retrofit.dart';

part 'expense_api.g.dart';

@RestApi()
abstract class ExpenseApi {
  factory ExpenseApi(Dio dio, {String? baseUrl}) = _ExpenseApi;

  @GET('expense/get')
  Future<TotalExpenseModel> getExpense();

  @GET("expense/getAll")
  Future<ExpensesModel> getAllExpenses();

  @GET("expense/stats")
  Future<ExpenseStatsModel> getExpenseStats();
}
