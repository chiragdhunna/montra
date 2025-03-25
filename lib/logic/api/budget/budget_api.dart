import 'package:dio/dio.dart';
import 'package:montra/logic/api/bank/models/total_bank_balance_model.dart';
import 'package:montra/logic/api/budget/models/budget_month_model.dart';
import 'package:montra/logic/api/budget/models/budgets_model.dart';
import 'package:montra/logic/api/budget/models/create_budget_model.dart';
import 'package:montra/logic/api/budget/models/delete_budget_model.dart';
import 'package:montra/logic/api/budget/models/update_budget_model.dart';
import 'package:retrofit/retrofit.dart';

part 'budget_api.g.dart';

@RestApi()
abstract class BudgetApi {
  factory BudgetApi(Dio dio, {String? baseUrl}) = _BudgetApi;

  @POST('budget/create')
  Future<void> createBudget(@Body() CreateBudgetModel budget);

  @POST('budget/update')
  Future<void> updateBudget(@Body() UpdateBudgetModel budget);

  @DELETE('budget/delete')
  Future<void> deleteBudget(@Body() DeleteBudgetModel budget);

  @GET('budget/balance')
  Future<TotalBankBalanceModel> getBalance();

  @GET("budget/getall")
  Future<BudgetsModel> getAllBudgets();

  @POST("budget/getbymonth")
  Future<BudgetsModel> getbymonth(@Body() BudgetMonthModel month);
}
