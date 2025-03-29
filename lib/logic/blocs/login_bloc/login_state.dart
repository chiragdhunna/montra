part of 'login_bloc.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loginSuccess() = _LoginSuccess;
  const factory LoginState.inProgress() = _InProgress;
  const factory LoginState.loginFail({required String error}) = _LoginFail;
}
