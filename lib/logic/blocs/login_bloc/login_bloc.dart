import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/users/models/login_user_model.dart';
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

  final userApi = UserApi(DioFactory().create());

  Future<void> _startLogin(_StartLogin event, Emitter<LoginState> emit) async {
    try {
      emit(LoginState.inProgress());
      final data = LoginUserModel(email: event.email, password: event.password);
      final response = await userApi.login(data);
      log.d('Response Data : $response');
      emit(LoginState.loginSuccess());
    } catch (e) {
      log.e('Error in StartLogin: ${e.toString()}');
      emit(LoginState.loginFail());
    }
  }

  Future<void> _verifyLogin(
    _VerifyLogin event,
    Emitter<LoginState> emit,
  ) async {
    try {
      emit(LoginState.inProgress());
      await Future.delayed(Duration(seconds: 2));
      emit(LoginState.loginSuccess());
    } catch (e) {
      emit(LoginState.loginFail());
    }
  }
}
