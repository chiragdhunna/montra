part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.started() = _Started;
  const factory LoginEvent.startLogin({
    required String email,
    required String password,
  }) = _StartLogin;
  const factory LoginEvent.signUp({
    required String name,
    required String email,
    required String password,
  }) = _SignUp;
  const factory LoginEvent.verifyLogin({required String authToken}) =
      _VerifyLogin;
}
