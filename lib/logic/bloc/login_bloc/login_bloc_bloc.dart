import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_bloc_event.dart';
part 'login_bloc_state.dart';
part 'login_bloc_bloc.freezed.dart';

class LoginBlocBloc extends Bloc<LoginBlocEvent, LoginBlocState> {
  LoginBlocBloc() : super(_Initial()) {
    on<LoginBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
