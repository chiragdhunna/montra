import 'package:dio/dio.dart';
import 'package:montra/logic/api/users/models/login_user_model.dart';
import 'package:montra/logic/api/users/models/login_user_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api.g.dart';

// Model classes based on API responses
// class SignupResponse {
//   final bool success;
//   final String message;

//   SignupResponse({required this.success, required this.message});

//   factory SignupResponse.fromJson(Map<String, dynamic> json) => SignupResponse(
//     success: json['success'] as bool,
//     message: json['message'] as String,
//   );

//   Map<String, dynamic> toJson() => {'success': success, 'message': message};
// }

// class LoginResponse {
//   final bool success;
//   final String token;

//   LoginResponse({required this.success, required this.token});

//   factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
//     success: json['success'] as bool,
//     token: json['token'] as String,
//   );

//   Map<String, dynamic> toJson() => {'success': success, 'token': token};
// }

// class UserDetails {
//   final int userId;
//   final String name;
//   final String email;
//   final String? imgUrl;

//   UserDetails({
//     required this.userId,
//     required this.name,
//     required this.email,
//     this.imgUrl,
//   });

//   factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
//     userId: json['user_id'] as int,
//     name: json['name'] as String,
//     email: json['email'] as String,
//     imgUrl: json['img_url'] as String?,
//   );

//   Map<String, dynamic> toJson() => {
//     'user_id': userId,
//     'name': name,
//     'email': email,
//     'img_url': imgUrl,
//   };
// }

// class UserResponse {
//   final bool success;
//   final UserDetails user;

//   UserResponse({required this.success, required this.user});

//   factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
//     success: json['success'] as bool,
//     user: UserDetails.fromJson(json['user'] as Map<String, dynamic>),
//   );

//   Map<String, dynamic> toJson() => {'success': success, 'user': user.toJson()};
// }

// // Request models
// class SignupRequest {
//   final String name;
//   final String email;
//   final String password;
//   final String pin;
//   final String? imgUrl;

//   SignupRequest({
//     required this.name,
//     required this.email,
//     required this.password,
//     required this.pin,
//     this.imgUrl,
//   });

//   Map<String, dynamic> toJson() => {
//     'name': name,
//     'email': email,
//     'password': password,
//     'pin': pin,
//     if (imgUrl != null) 'imgUrl': imgUrl,
//   };
// }

// class ExportRequest {
//   final String dataType;
//   final String dateRange;
//   final String format;

//   ExportRequest({
//     this.dataType = 'all',
//     this.dateRange = '1month',
//     this.format = 'csv',
//   });

//   Map<String, dynamic> toJson() => {
//     'dataType': dataType,
//     'dateRange': dateRange,
//     'format': format,
//   };
// }

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String? baseUrl}) = _UserApi;

  // @POST('/api/v1/user/signup')
  // Future<SignupResponse> signup(@Body() SignupRequest request);

  @POST('users/login')
  Future<LoginUserResponseModel> login(@Body() LoginUserModel request);

  // @MultiPart()
  // @POST('/api/v1/user/imageupload')
  // Future<String> uploadImage(@Part() File file);

  // @GET('/api/v1/user/getimage')
  // // Use responseType parameter instead of Headers annotation
  // Future<List<int>> getImage({
  //   @Query('responseType') String responseType = 'bytes',
  // });

  // @POST('/api/v1/user/export')
  // Future<List<int>> exportData(@Body() ExportRequest request);

  // @GET('/api/v1/user/getme')
  // Future<UserResponse> getMe();
}
