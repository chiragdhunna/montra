import 'package:dio/dio.dart';
import 'package:montra/logic/api/transfer/models/create_transfer_model.dart';
import 'package:montra/logic/api/transfer/models/transfers_model.dart';
import 'package:retrofit/retrofit.dart';

part 'transfer_api.g.dart';

@RestApi()
abstract class TransferApi {
  factory TransferApi(Dio dio, {String? baseUrl}) = _TransferApi;

  @GET("transfer/getAll")
  Future<TransfersModel> getAllTransfers();

  @POST("transfer/add")
  Future<void> createTransfer(@Body() CreateTransferModel transfer);
}
