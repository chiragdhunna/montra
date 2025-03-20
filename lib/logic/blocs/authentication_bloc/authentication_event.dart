part of 'authentication_bloc.dart';

@freezed
class AuthenticationEvent with _$AuthenticationEvent {
  const factory AuthenticationEvent.started() = _Started;

  const factory AuthenticationEvent.checkExisting() = _CheckExisting;

  const factory AuthenticationEvent.userLogin({
    required String authToken,
    required UserModel user,
  }) = _UserLogin;

  const factory AuthenticationEvent.userSignUp({
    required String authToken,
    required UserModel user,
  }) = _UserSignUp;

  const factory AuthenticationEvent.logout() = _Logout;

  const factory AuthenticationEvent.userProfileUpdate({
    required UserModel userModel,
  }) = _UserProfileUpdated;

  const factory AuthenticationEvent.uploadProfileImage(File image) =
      _UploadProfileImage;
}
