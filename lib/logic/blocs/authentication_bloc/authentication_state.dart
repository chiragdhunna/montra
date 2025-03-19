part of 'authentication_bloc.dart';

@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.initial() = _Initial;

  factory AuthenticationState.checking() = _Checking;

  factory AuthenticationState.inProgress({
    required String email,
    required int attempt,
  }) = _InProgess;

  factory AuthenticationState.authenticated({
    required UserModel user,
    required String authToken,
  }) = _Authenticated;

  factory AuthenticationState.unAuthenticated() = _UnAuthenticated;
  factory AuthenticationState.loggedOut() = _LoggedOut;

  factory AuthenticationState.userLoggedIn({
    required UserModel user,
    required String authToken,
  }) = _UserLoggedIn;
}
