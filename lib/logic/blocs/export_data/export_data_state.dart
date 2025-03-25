part of 'export_data_bloc.dart';

@freezed
class ExportDataState with _$ExportDataState {
  const factory ExportDataState.initial() = _Initial;
  const factory ExportDataState.inProgress() = _InProgress;
  const factory ExportDataState.failure({required String error}) = _Failure;
  const factory ExportDataState.getExportDataSuccess({String? filePath}) =
      _GetExportDataSuccess;
}
