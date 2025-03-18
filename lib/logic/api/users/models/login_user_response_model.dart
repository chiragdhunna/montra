import 'package:freezed_annotation/freezed_annotation.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'login_user_response_model.freezed.dart';
// optional: Since our LoginUserResponseModel class is serializable, we must add this line.
// But if LoginUserResponseModel was not serializable, we could skip it.
part 'login_user_response_model.g.dart';

@freezed
abstract class LoginUserResponseModel with _$LoginUserResponseModel {
  const factory LoginUserResponseModel({
    required String email,
    required String password,
  }) = _LoginUserResponseModel;

  factory LoginUserResponseModel.fromJson(Map<String, Object?> json) =>
      _$LoginUserResponseModelFromJson(json);
}
