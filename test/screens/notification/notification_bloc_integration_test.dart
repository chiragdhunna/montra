import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/logic/blocs/notification_bloc/notification_bloc.dart';
import 'package:montra/screens/notification/notification_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationBloc extends Mock implements NotificationBloc {}

class FakeNotificationState extends Fake implements NotificationState {}

class FakeNotificationEvent extends Fake implements NotificationEvent {}

void main() {
  late MockNotificationBloc mockNotificationBloc;
  final notificationsData = [
    {
      'title': 'Test Notification',
      'subtitle': 'This is a test notification',
      'time': '10:30',
    },
    {
      'title': 'Payment Due',
      'subtitle': 'Your payment is due tomorrow',
      'time': '12:45',
    },
  ];

  setUpAll(() {
    registerFallbackValue(FakeNotificationState());
    registerFallbackValue(FakeNotificationEvent());
  });

  setUp(() {
    mockNotificationBloc = MockNotificationBloc();
  });

  testWidgets('NotificationScreen should listen to bloc state changes', (
    WidgetTester tester,
  ) async {
    // Create a controller to emit state changes on demand
    final controller = StreamController<NotificationState>();

    // Set up the mock bloc
    when(
      () => mockNotificationBloc.state,
    ).thenReturn(const NotificationState.inProgress());

    when(
      () => mockNotificationBloc.stream,
    ).thenAnswer((_) => controller.stream);

    when(
      () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
    ).thenAnswer((_) => Future.value());

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<NotificationBloc>.value(
          value: mockNotificationBloc,
          child: const NotificationScreen(),
        ),
      ),
    );

    // Initially shows loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Emit a state with notifications
    controller.add(
      NotificationState.getAllNotificationSuccess(data: notificationsData),
    );
    await tester.pumpAndSettle();

    // Now it should show the notifications
    expect(find.text('Test Notification'), findsOneWidget);
    expect(find.text('Payment Due'), findsOneWidget);

    // Emit an empty state
    controller.add(const NotificationState.getAllNotificationSuccess(data: []));
    await tester.pumpAndSettle();

    // Now it should show the empty message
    expect(find.text('There is no notification for now'), findsOneWidget);

    // Emit a failure state
    controller.add(
      const NotificationState.failure(error: 'Error loading notifications'),
    );
    await tester.pumpAndSettle();

    // Should show the error message in a snackbar
    expect(find.text('Error loading notifications'), findsOneWidget);

    // Clean up
    controller.close();
  });
}
