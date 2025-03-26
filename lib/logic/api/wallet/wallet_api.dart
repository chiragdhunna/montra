import 'package:dio/dio.dart';
import 'package:montra/logic/api/bank/models/bank_transaction_model.dart';
import 'package:montra/logic/api/wallet/models/create_wallet_model.dart';
import 'package:montra/logic/api/wallet/models/total_wallet_balance_model.dart';
import 'package:montra/logic/api/wallet/models/update_wallet_model.dart';
import 'package:montra/logic/api/wallet/models/wallet_name_model.dart';
import 'package:montra/logic/api/wallet/models/wallet_names_model.dart';
import 'package:montra/logic/api/wallet/models/wallets_model.dart';
import 'package:retrofit/retrofit.dart';

part 'wallet_api.g.dart';

@RestApi()
abstract class WalletApi {
  factory WalletApi(Dio dio, {String? baseUrl}) = _WalletApi;

  @GET('wallet/balance')
  Future<TotalWalletBalanceModel> getBalance();

  @POST('wallet/create')
  Future<void> createWallet(@Body() CreateWalletModel request);

  @GET("wallet/getall")
  Future<WalletsModel> getAllWalletAccounts();

  @GET("wallet/wallets")
  Future<WalletNamesModel> getAllWalletNames();

  @POST("wallet/transactions")
  Future<BankTransactionModel> getAllWalletTransactions(
    @Body() WalletNameModel walletName,
  );

  @PUT("wallet/update")
  Future<void> updateWalletById(@Body() UpdateWalletModel updateWalletModel);
}
