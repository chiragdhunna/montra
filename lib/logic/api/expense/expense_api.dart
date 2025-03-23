import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/logic/api/expense/models/expense_stats_model.dart';
import 'package:montra/logic/api/expense/models/expense_stats_summary_model.dart';
import 'package:montra/logic/api/expense/models/total_expense_model.dart';
import 'package:montra/logic/api/income/models/income_model.dart';
import 'package:montra/logic/api/income/models/total_income_model.dart';
import 'package:montra/logic/api/users/models/login_user_model.dart';
import 'package:montra/logic/api/users/models/login_user_response_model.dart';
import 'package:montra/logic/api/users/models/user_image_model.dart';
import 'package:montra/logic/api/users/models/user_model.dart';
import 'package:retrofit/retrofit.dart';

part 'expense_api.g.dart';

@RestApi()
abstract class ExpenseApi {
  factory ExpenseApi(Dio dio, {String? baseUrl}) = _ExpenseApi;

  // @POST('income/add')
  // Future<LoginUserResponseModel> addIncome(@Body() IncomeModel request);

  @GET('expense/get')
  Future<TotalExpenseModel> getExpense();

  // @DELETE('income/delete')
  // Future<LoginUserResponseModel> deleteIncome(@Body() LoginUserModel request);

  @GET("expense/all")
  Future<UserImageModel> getAllExpenses(@Body() FormData formData);

  @GET("expense/stats")
  Future<ExpenseStatsModel> getExpenseStats();
}
