import 'package:dio/dio.dart';
import 'package:montra/logic/api/bank/models/bank_name_model.dart';
import 'package:montra/logic/api/bank/models/bank_transaction_model.dart';
import 'package:montra/logic/api/bank/models/banks_model.dart';
import 'package:montra/logic/api/bank/models/create_bank_account_model.dart';
import 'package:montra/logic/api/bank/models/total_bank_balance_model.dart';
import 'package:montra/logic/api/bank/models/update_bank_model.dart';
import 'package:retrofit/retrofit.dart';

part 'bank_api.g.dart';

@RestApi()
abstract class BankApi {
  factory BankApi(Dio dio, {String? baseUrl}) = _BankApi;

  @POST('bank/create')
  Future<void> createBankAccount(@Body() CreateBankAccountModel bankAccount);

  @GET('bank/balance')
  Future<TotalBankBalanceModel> getBalance();

  @GET("bank/get")
  Future<BanksModel> getAllBankAccounts();

  @POST("bank/transactions")
  Future<BankTransactionModel> getAllBankTransactions(
    @Body() BankNameModel bankName,
  );

  @POST("bank/update")
  Future<void> updateBankBalance(@Body() UpdateBankModel updateBankModel);
}
