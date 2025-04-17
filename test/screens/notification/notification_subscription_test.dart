import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:montra/logic/blocs/notification_bloc/notification_bloc.dart';
import 'package:montra/screens/notification/notification_screen.dart';

class MockNotificationBloc extends Mock implements NotificationBloc {}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}

class FakeNotificationState extends Fake implements NotificationState {}

class FakeNotificationEvent extends Fake implements NotificationEvent {}

void main() {
  late MockNotificationBloc mockNotificationBloc;
  late StreamController<NotificationState> controller;
  late MockStreamSubscription<NotificationState> mockSubscription;

  setUpAll(() {
    registerFallbackValue(FakeNotificationState());
    registerFallbackValue(FakeNotificationEvent());
  });

  setUp(() {
    mockNotificationBloc = MockNotificationBloc();
    controller = StreamController<NotificationState>();
    mockSubscription = MockStreamSubscription<NotificationState>();
  });

  tearDown(() {
    controller.close();
  });

  testWidgets(
    'NotificationScreen should cancel stream subscription when disposed',
    (WidgetTester tester) async {
      // Setup mock bloc
      when(
        () => mockNotificationBloc.state,
      ).thenReturn(const NotificationState.inProgress());

      when(
        () => mockNotificationBloc.stream,
      ).thenAnswer((_) => controller.stream);

      when(
        () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
      ).thenAnswer((_) => Future.value());

      // Mock stream.listen to return our mock subscription
      when(
        () => mockNotificationBloc.stream.listen(any()),
      ).thenReturn(mockSubscription);

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotificationBloc>.value(
            value: mockNotificationBloc,
            child: const NotificationScreen(),
          ),
        ),
      );

      // Navigate away to trigger disposal
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Verify subscription was canceled
      verify(() => mockSubscription.cancel()).called(1);
    },
  );
}
