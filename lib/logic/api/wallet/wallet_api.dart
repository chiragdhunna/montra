import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/logic/api/bank/models/total_bank_balance_model.dart';
import 'package:montra/logic/api/expense/models/total_expense_model.dart';
import 'package:montra/logic/api/income/models/income_model.dart';
import 'package:montra/logic/api/income/models/total_income_model.dart';
import 'package:montra/logic/api/users/models/login_user_model.dart';
import 'package:montra/logic/api/users/models/login_user_response_model.dart';
import 'package:montra/logic/api/users/models/user_image_model.dart';
import 'package:montra/logic/api/users/models/user_model.dart';
import 'package:montra/logic/api/wallet/models/total_wallet_balance_model.dart';
import 'package:retrofit/retrofit.dart';

part 'wallet_api.g.dart';

@RestApi()
abstract class WalletApi {
  factory WalletApi(Dio dio, {String? baseUrl}) = _WalletApi;

  // @POST('income/add')
  // Future<LoginUserResponseModel> addIncome(@Body() IncomeModel request);

  @GET('wallet/balance')
  Future<TotalWalletBalanceModel> getBalance();

  // @DELETE('income/delete')
  // Future<LoginUserResponseModel> deleteIncome(@Body() LoginUserModel request);

  @GET("income/all")
  Future<UserImageModel> getAllBankAccounts(@Body() FormData formData);
}
