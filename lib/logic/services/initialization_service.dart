import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/logic/api/wallet/wallet_api.dart';
import 'package:montra/logic/blocs/income_bloc/income_bloc.dart';
import 'package:montra/logic/database/database_helper.dart';
import 'package:montra/logic/dio_factory.dart';
import 'package:logger/logger.dart';

class InitializationService {
  Future<void> initializeWallets() async {
    IncomeBloc().add(IncomeEvent.getWallets());
  }
}
