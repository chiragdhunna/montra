import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:montra/logic/blocs/network_bloc/network_bloc.dart';

class NetworkHelper {
  static void observeNetwork(NetworkBloc networkBloc) {
    final connectivity = Connectivity();

    connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Check if the device is completely offline
      bool isConnected =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);

      networkBloc.add(NetworkEvent.notify(isConnected: isConnected));
    });
  }
}
