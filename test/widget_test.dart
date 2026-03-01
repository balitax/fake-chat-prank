// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fake_chat_simulator/main.dart';
import 'package:fake_chat_simulator/services/storage_service.dart';

void main() {
  testWidgets('FakeChatApp smoke test - app loads and shows empty state', (WidgetTester tester) async {
    // Set up mock shared preferences for testing
    SharedPreferences.setMockInitialValues({});
    
    // Create and initialize the storage service
    final storageService = StorageService();
    await storageService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(FakeChatApp(storageService: storageService, initialDarkMode: false));

    // Wait for the async load to complete
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('WhatsApp'), findsOneWidget);

    // Verify that the empty state is shown (no projects)
    expect(find.text('No chats yet'), findsOneWidget);

    // Verify that the "New Chat" button exists
    expect(find.text('New Chat'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('FakeChatApp smoke test - theme toggle button exists', (WidgetTester tester) async {
    // Set up mock shared preferences for testing
    SharedPreferences.setMockInitialValues({});

    // Create and initialize the storage service
    final storageService = StorageService();
    await storageService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(FakeChatApp(storageService: storageService, initialDarkMode: false));

    // Wait for the async load to complete
    await tester.pumpAndSettle();

    // Verify that theme toggle button exists
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });
}
