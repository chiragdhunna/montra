import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/logic/blocs/network_bloc/network_helper.dart';

part 'network_event.dart';
part 'network_state.dart';
part 'network_bloc.freezed.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  factory NetworkBloc() => _instance;
  NetworkBloc._() : super(const _Initial()) {
    on<_Notify>(_notifyStatus);
    on<_Observer>(_observe);
  }

  static final NetworkBloc _instance = NetworkBloc._();

  void _observe(_Observer event, Emitter<NetworkState> emit) {
    NetworkHelper.observeNetwork(NetworkBloc());
  }

  void _notifyStatus(_Notify event, Emitter<NetworkState> emit) {
    event.isConnected
        ? emit(const NetworkState.success())
        : emit(const NetworkState.failure());
  }
}
