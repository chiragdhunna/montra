import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/users/models/login_user_model.dart';
import 'package:montra/logic/api/users/models/user_model.dart';
import 'package:montra/logic/api/users/user_api.dart';
import 'package:montra/logic/dio_factory.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(_Initial()) {
    on<_StartLogin>(_startLogin);
    on<_VerifyLogin>(_verifyLogin);
  }

  final String _logTag = 'LoginBloc';
  final _userApi = UserApi(DioFactory().create());

  Future<void> _startLogin(_StartLogin event, Emitter<LoginState> emit) async {
    emit(const LoginState.inProgress());

    try {
      await Future.delayed(const Duration(seconds: 1), () {
        emit(
          LoginState.loginStarted(
            phone: event.phone,
            attempts: event.attempts + 1,
          ),
        );
      });
    } on Exception catch (error, stackTrace) {
      log.e(_logTag, error: error, stackTrace: stackTrace);
      addError(error, stackTrace);
      emit(LoginState.error(error.toString()));
    }
  }

  Future<void> _verifyLogin(
    _VerifyLogin event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginState.inProgress());

    try {
      final loggedInUser = await _userApi.login(
        LoginUserModel(email: event.phone, password: event.otp),
      );

      emit(
        LoginState.loginUserSuccess(
          authToken: loggedInUser.token,
          user: UserModel(
            name: 'name',
            email: 'email',
            password: 'password',
            userId: 'userId',
          ),
        ),
      );

      // _authenticationBloc.add(
      //   AuthenticationEvent.newUserLogin(
      //     authToken: loggedInUser.accessToken,
      //     user: loggedInUser.user,
      //   ),
      // );
    } on Exception catch (error, stackTrace) {
      if (error is DioException) {
        log.e(_logTag, error: error, stackTrace: stackTrace);
        if (error.response!.data['detail'] == 'Otp mismatch') {
          emit(const LoginState.error('Otp mismatch'));
        }
      } else {
        log.e(_logTag, error: error, stackTrace: stackTrace);
        addError(error, stackTrace);
        emit(LoginState.error(error.toString()));
      }
    }
  }
}
