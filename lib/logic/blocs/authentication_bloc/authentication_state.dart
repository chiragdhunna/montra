part of 'authentication_bloc.dart';

@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.initial() = _Initial;

  factory AuthenticationState.checking() = _Checking;

  factory AuthenticationState.failure({required String error}) = _Failure;

  factory AuthenticationState.inProgress() = _InProgess;

  factory AuthenticationState.authenticated({
    required UserModel user,
    required String authToken,
  }) = _Authenticated;

  factory AuthenticationState.unAuthenticated() = _UnAuthenticated;
  factory AuthenticationState.loggedOut() = _LoggedOut;

  factory AuthenticationState.userSignedUp() = _UserSignedUp;

  factory AuthenticationState.userImageUploaded({required UserModel user}) =
      _UserImageUploaded;

  factory AuthenticationState.userLoggedIn({
    required UserModel user,
    required String authToken,
  }) = _UserLoggedIn;
}

extension AuthenticationStateX on AuthenticationState {
  bool get isAuthenticated => this is _Authenticated || this is _UserLoggedIn;
}
