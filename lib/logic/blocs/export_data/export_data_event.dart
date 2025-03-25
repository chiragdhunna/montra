part of 'export_data_bloc.dart';

@freezed
class ExportDataEvent with _$ExportDataEvent {
  const factory ExportDataEvent.started() = _Started;
  const factory ExportDataEvent.showFile() = _ShowFile;
  const factory ExportDataEvent.getExportData({
    required String dataType,
    required String dateRange,
    required String format,
  }) = _GetExportData;
}
