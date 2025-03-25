import 'package:dio/dio.dart';
import 'package:montra/logic/api/income/models/incomes_model.dart';
import 'package:montra/logic/api/income/models/total_income_model.dart';
import 'package:retrofit/retrofit.dart';

part 'income_api.g.dart';

@RestApi()
abstract class IncomeApi {
  factory IncomeApi(Dio dio, {String? baseUrl}) = _IncomeApi;

  @GET('income/get')
  Future<TotalIncomeModel> getIncome();

  @GET("income/all")
  Future<IncomesModel> getAllIncomes();

  @POST("income/add")
  Future<void> createIncome(@Body() FormData income);
}
