part of 'notification_bloc.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = _Initial;
  const factory NotificationState.failure({required String error}) = _Failure;
  const factory NotificationState.inProgress() = _InProgress;
  const factory NotificationState.getAllNotificationSuccess({
    required dynamic data,
  }) = _GetAllNotificationSuccess;
}
