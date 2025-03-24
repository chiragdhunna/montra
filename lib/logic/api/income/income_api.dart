import 'package:dio/dio.dart';
import 'package:montra/logic/api/income/models/total_income_model.dart';
import 'package:montra/logic/api/users/models/user_image_model.dart';
import 'package:retrofit/retrofit.dart';

part 'income_api.g.dart';

@RestApi()
abstract class IncomeApi {
  factory IncomeApi(Dio dio, {String? baseUrl}) = _IncomeApi;

  // @POST('income/add')
  // Future<LoginUserResponseModel> addIncome(@Body() IncomeModel request);

  @GET('income/get')
  Future<TotalIncomeModel> getIncome();

  // @DELETE('income/delete')
  // Future<LoginUserResponseModel> deleteIncome(@Body() LoginUserModel request);

  @GET("income/all")
  Future<UserImageModel> getAllIncomes(@Body() FormData formData);
}
