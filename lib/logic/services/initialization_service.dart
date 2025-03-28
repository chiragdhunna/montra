import 'package:montra/logic/blocs/income_bloc/income_bloc.dart';

class InitializationService {
  Future<void> initializeWallets() async {
    IncomeBloc().add(IncomeEvent.getWallets());
  }
}
