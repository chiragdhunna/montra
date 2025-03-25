import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/users/models/export_data_user_model.dart';
import 'package:montra/logic/api/users/user_api.dart';
import 'package:montra/logic/dio_factory.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

part 'export_data_event.dart';
part 'export_data_state.dart';
part 'export_data_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class ExportDataBloc extends Bloc<ExportDataEvent, ExportDataState> {
  ExportDataBloc() : super(_Initial()) {
    on<ExportDataEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<_GetExportData>(_getExportData);
  }

  final _userApi = UserApi(DioFactory().create());

  Future<void> _getExportData(
    _GetExportData event,
    Emitter<ExportDataState> emit,
  ) async {
    try {
      emit(ExportDataState.inProgress());

      // 1. Ask for permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          emit(
            const ExportDataState.failure(error: "Storage permission denied"),
          );
          return;
        }
      }

      // 2. Create export request model
      final exportDataModel = ExportDataUserModel(
        dataType: event.dataType,
        dateRange: event.dateRange,
        format: event.format,
      );

      // 3. Call API
      final response = await _userApi.exportData(exportDataModel);

      // 4. Get save path
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        emit(const ExportDataState.failure(error: "Unable to access storage"));
        return;
      }

      final fileName =
          'financial_report_${DateTime.now().millisecondsSinceEpoch}.${event.format}';
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      // 5. Save bytes to file
      await file.writeAsBytes(response.data);

      // 6. Optionally open the file
      await OpenFile.open(filePath);

      // emit(ExportDataState.getExportDataSuccess(filePath: filePath));
    } catch (e) {
      log.e('Download Error: $e');
      emit(ExportDataState.failure(error: e.toString()));
    }
  }
}
