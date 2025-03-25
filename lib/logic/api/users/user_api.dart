import 'package:dio/dio.dart';
import 'package:montra/logic/api/users/models/export_data_user_model.dart';
import 'package:montra/logic/api/users/models/login_user_model.dart';
import 'package:montra/logic/api/users/models/login_user_response_model.dart';
import 'package:montra/logic/api/users/models/user_image_model.dart';
import 'package:montra/logic/api/users/models/user_model.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String? baseUrl}) = _UserApi;

  @POST('users/signup')
  Future<LoginUserResponseModel> signup(@Body() UserModel request);

  @POST('users/login')
  Future<LoginUserResponseModel> login(@Body() LoginUserModel request);

  @POST("users/imageupload")
  Future<UserImageModel> uploadImage(@Body() FormData formData);

  @GET('users/getimage')
  @DioResponseType(ResponseType.bytes) // This tells Dio to expect binary data
  Future<HttpResponse<List<int>>> getImage();

  @POST('users/export')
  @DioResponseType(ResponseType.bytes) // This tells Dio to expect file content
  Future<HttpResponse<List<int>>> exportData(
    @Body() ExportDataUserModel request,
  );
}
