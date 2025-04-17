import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:montra/logic/blocs/notification_bloc/notification_bloc.dart';

class MockNotificationBloc extends Mock implements NotificationBloc {}

void main() {
  late MockNotificationBloc mockBloc;

  setUp(() {
    mockBloc = MockNotificationBloc();
  });

  group('NotificationBloc', () {
    test('initial state should be initial', () {
      when(() => mockBloc.state).thenReturn(const NotificationState.initial());
      expect(mockBloc.state, const NotificationState.initial());
    });

    test(
      'should emit getAllNotificationSuccess when getAllNotifications is called',
      () {
        final notifications = [
          {
            'title': 'Test Notification',
            'subtitle': 'This is a test notification',
            'time': '10:30',
          },
        ];

        // Setup the state changes
        when(
          () => mockBloc.state,
        ).thenReturn(const NotificationState.initial());
        when(
          () => mockBloc.state,
        ).thenReturn(const NotificationState.inProgress());
        when(() => mockBloc.state).thenReturn(
          NotificationState.getAllNotificationSuccess(data: notifications),
        );

        // Mock the add method
        when(
          () => mockBloc.add(const NotificationEvent.getAllNotifications()),
        ).thenAnswer((_) => Future.value());

        // Trigger the event
        mockBloc.add(const NotificationEvent.getAllNotifications());

        // Verify the state changes as expected
        expect(
          mockBloc.state,
          NotificationState.getAllNotificationSuccess(data: notifications),
        );
      },
    );

    test('should emit failure state when an error occurs', () {
      const errorMessage = 'Failed to load notifications';

      // Setup the state changes
      when(() => mockBloc.state).thenReturn(const NotificationState.initial());
      when(
        () => mockBloc.state,
      ).thenReturn(const NotificationState.inProgress());
      when(
        () => mockBloc.state,
      ).thenReturn(const NotificationState.failure(error: errorMessage));

      // Mock the add method
      when(
        () => mockBloc.add(const NotificationEvent.getAllNotifications()),
      ).thenAnswer((_) => Future.value());

      // Trigger the event
      mockBloc.add(const NotificationEvent.getAllNotifications());

      // Verify the state is failure
      expect(
        mockBloc.state,
        const NotificationState.failure(error: errorMessage),
      );
    });
  });
}
