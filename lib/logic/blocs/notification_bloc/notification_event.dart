part of 'notification_bloc.dart';

@freezed
class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.started() = _Started;
  const factory NotificationEvent.getAllNotifications() = _GetAllNotifications;
  const factory NotificationEvent.clearAllNotifications() =
      _ClearAllNotifications;
}
