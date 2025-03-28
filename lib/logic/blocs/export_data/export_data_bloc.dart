import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
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
    on<_ShowFile>(_showFile);
  }

  final _userApi = UserApi(DioFactory().create());
  String exportFilePath = "";

  Future<void> _getExportData(
    _GetExportData event,
    Emitter<ExportDataState> emit,
  ) async {
    try {
      emit(ExportDataState.inProgress());

      // ✅ Android 13+ Permissions Handling
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.request().isGranted ||
            await Permission.photos.request().isGranted ||
            await Permission.videos.request().isGranted ||
            await Permission.audio.request().isGranted) {
          log.i("Storage permission granted.");
        } else {
          emit(
            const ExportDataState.failure(error: "Storage permission denied"),
          );
          return;
        }
      }

      // ✅ Create File Name
      final fileName =
          'financial_report_${DateTime.now().millisecondsSinceEpoch}.${event.format}';

      // ✅ 1. Call API to Get File Data
      final exportDataModel = ExportDataUserModel(
        dataType: event.dataType,
        dateRange: event.dateRange,
        format: event.format,
      );
      final response = await _userApi.exportData(exportDataModel);

      final List<int> fileBytes = response.data; // Get raw bytes
      if (fileBytes.isEmpty) {
        emit(const ExportDataState.failure(error: "Failed to get file data."));
        return;
      }

      // ✅ 2. Convert `List<int>` to `Uint8List`
      Uint8List uint8ListBytes = Uint8List.fromList(fileBytes);

      // ✅ 3. Use `FilePicker.platform.saveFile()` to save the file
      String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: "Save file to...",
        fileName: fileName,
        bytes: uint8ListBytes, // ✅ FIX: Convert List<int> → Uint8List
      );

      if (savePath == null) {
        emit(
          const ExportDataState.failure(error: "User canceled file selection"),
        );
        return;
      }

      // ✅ 4. Manually Write Bytes to File
      final file = File(savePath);
      await file.writeAsBytes(uint8ListBytes);

      // ✅ 5. Open the File After Saving
      if (await file.exists()) {
        await OpenFile.open(savePath);
      } else {
        emit(
          const ExportDataState.failure(error: "File not found after saving"),
        );
        return;
      }

      exportFilePath = savePath;
      emit(ExportDataState.getExportDataSuccess(filePath: savePath));
    } catch (e) {
      log.e('Download Error: $e');
      emit(ExportDataState.failure(error: e.toString()));
    }
  }

  Future<void> _showFile(_ShowFile event, Emitter<ExportDataState> emit) async {
    try {
      await OpenFile.open(exportFilePath);
    } catch (e) {
      log.e('Download Error: $e');
      emit(ExportDataState.failure(error: e.toString()));
    }
  }
}
