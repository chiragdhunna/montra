import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/users/models/user_model.dart';
import 'package:montra/logic/api/users/user_api.dart';
import 'package:montra/logic/blocs/authentication_bloc/auth_repository.dart';
import 'package:montra/logic/blocs/network_bloc/network_bloc.dart';
import 'package:montra/logic/dio_factory.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';
part 'authentication_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  factory AuthenticationBloc() {
    return _instance;
  }
  AuthenticationBloc._internal() : super(_Initial()) {
    on<_CheckExisting>(_checkExisting);
    on<_UserLogin>(_userLoggedIn);
    on<_Logout>(_logout);
  }

  final String _logTag = 'LoginBloc';

  static final AuthenticationBloc _instance = AuthenticationBloc._internal();
  final _authRepository = AuthRepository(
    userApi: UserApi(DioFactory().create()),
  );

  Future<void> _logout(_Logout event, Emitter<AuthenticationState> emit) async {
    try {
      await _authRepository.logout();
      /* Login for updating the device token to the backend */
      emit(AuthenticationState.loggedOut());
      add(const AuthenticationEvent.checkExisting());
    } on Exception catch (error, stackTrace) {
      log.e(_logTag, error: 'Caught an exception  $error     $stackTrace');
    }
  }

  Future<void> _userLoggedIn(
    _UserLogin event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      log.d('Auth token for user is : ${event.authToken}');
      await _authRepository.setAuthToken(event.authToken);
      await _authRepository.setUser(event.user);
      // final user = await _authRepository.userApi.getMe();

      emit(
        AuthenticationState.userLoggedIn(
          user: event.user,
          authToken: event.authToken,
        ),
      );
    } on Exception catch (error, stackTrace) {
      log.e(_logTag, error: 'Caught an exception  $error     $stackTrace');
    }
  }

  Future<void> _checkExisting(
    _CheckExisting event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      final authToken = await _authRepository.getAuthToken();
      final authUser = await _authRepository.getAuthUser();
      var isOnline = false;
      NetworkBloc().state.maybeWhen(
        success: () {
          isOnline = true;
        },
        failure: () {
          isOnline = false;
        },
        orElse: () {},
      );

      if (authToken != null && authUser != null) {
        // final user = await _authRepository.userApi.getMe();

        emit(
          AuthenticationState.authenticated(
            user: authUser,
            authToken: authToken,
          ),
        );
      } else {
        emit(AuthenticationState.unAuthenticated());
      }
    } on Exception catch (error, stackTrace) {
      log.e(_logTag, error: 'Caught an exception  $error     $stackTrace');
      emit(AuthenticationState.unAuthenticated());
    }
  }

  bool isAuthenticated() {
    return state.isAuthenticated;
  }
}
