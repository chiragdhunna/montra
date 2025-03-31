import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:montra/constants/error_message.dart';
import 'package:montra/logic/database/database_helper.dart';

part 'notification_event.dart';
part 'notification_state.dart';
part 'notification_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(_Initial()) {
    on<NotificationEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<_GetAllNotifications>(_addNotification);
    on<_ClearAllNotifications>(_clearAllNotifications);
  }

  final dbHelper = DatabaseHelper();

  Future<void> _addNotification(
    _GetAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationState.inProgress());

      final data = await dbHelper.getNotifications();

      emit(NotificationState.getAllNotificationSuccess(data: data));
    } catch (e) {
      log.e(e.toString());
      final message = errorMessage(e.toString());
      emit(NotificationState.failure(error: message));
    }
  }

  Future<void> _clearAllNotifications(
    _ClearAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationState.inProgress());

      await dbHelper.clearAllNotifications();

      emit(NotificationState.getAllNotificationSuccess(data: []));
    } catch (e) {
      log.e(e.toString());
      final message = errorMessage(e.toString());
      emit(NotificationState.failure(error: message));
    }
  }
}
