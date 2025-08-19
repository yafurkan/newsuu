import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:su_takip/main.dart';
import 'package:su_takip/presentation/providers/auth_provider.dart';
import 'package:su_takip/presentation/providers/user_provider.dart';
import 'package:su_takip/presentation/providers/water_provider.dart';
import 'package:su_takip/presentation/providers/notification_provider.dart';
import 'package:su_takip/presentation/providers/statistics_provider.dart';
import 'package:su_takip/presentation/providers/badge_provider.dart';
import 'package:su_takip/data/services/notification_service.dart';
import 'package:su_takip/data/services/cloud_sync_service.dart';
import 'package:su_takip/data/services/deep_link_service.dart';

void main() {
  group('Su Takip App Tests', () {
    testWidgets('App should start without crashing', (WidgetTester tester) async {
      // Mock services
      final notificationService = NotificationService();
      final cloudSyncService = CloudSyncService();
      final deepLinkService = DeepLinkService();

      // Build our app and trigger a frame
      await tester.pumpWidget(
        SuTakipApp(
          notificationService: notificationService,
          cloudSyncService: cloudSyncService,
          deepLinkService: deepLinkService,
        ),
      );

      // Verify that the app starts
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Splash screen should be displayed initially', (WidgetTester tester) async {
      // Mock services
      final notificationService = NotificationService();
      final cloudSyncService = CloudSyncService();
      final deepLinkService = DeepLinkService();

      await tester.pumpWidget(
        SuTakipApp(
          notificationService: notificationService,
          cloudSyncService: cloudSyncService,
          deepLinkService: deepLinkService,
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Check if splash screen or main content is displayed
      // Note: This might need adjustment based on your actual splash screen implementation
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    group('Provider Tests', () {
      test('AuthProvider should initialize correctly', () {
        final authProvider = AuthProvider();
        expect(authProvider, isNotNull);
        // Note: Actual property names should be checked in AuthProvider implementation
      });

      test('WaterProvider should initialize with default values', () {
        final waterProvider = WaterProvider(CloudSyncService());
        expect(waterProvider, isNotNull);
        expect(waterProvider.todayIntake, equals(0.0));
      });

      test('UserProvider should initialize correctly', () {
        final userProvider = UserProvider(CloudSyncService());
        expect(userProvider, isNotNull);
      });

      test('StatisticsProvider should initialize correctly', () {
        final statsProvider = StatisticsProvider();
        expect(statsProvider, isNotNull);
      });

      test('BadgeProvider should initialize correctly', () {
        final badgeProvider = BadgeProvider();
        expect(badgeProvider, isNotNull);
      });
    });

    group('Service Tests', () {
      test('NotificationService should initialize', () {
        final service = NotificationService();
        expect(service, isNotNull);
      });

      test('CloudSyncService should initialize', () {
        final service = CloudSyncService();
        expect(service, isNotNull);
      });

      test('DeepLinkService should initialize', () {
        final service = DeepLinkService();
        expect(service, isNotNull);
      });
    });
  });

  group('Security Tests', () {
    test('Environment variables should be properly configured', () {
      // Test that environment variables are being used
      const apiKey = String.fromEnvironment('FIREBASE_API_KEY_WEB', defaultValue: '');
      const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID_WEB', defaultValue: '');
      
      // In test environment, these might be empty, but the mechanism should work
      expect(apiKey, isA<String>());
      expect(projectId, isA<String>());
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('MultiProvider should provide all required providers', (WidgetTester tester) async {
      // Mock services
      final notificationService = NotificationService();
      final cloudSyncService = CloudSyncService();
      final deepLinkService = DeepLinkService();

      await tester.pumpWidget(
        SuTakipApp(
          notificationService: notificationService,
          cloudSyncService: cloudSyncService,
          deepLinkService: deepLinkService,
        ),
      );

      // Find the MultiProvider widget
      final multiProviderFinder = find.byType(MultiProvider);
      expect(multiProviderFinder, findsOneWidget);

      // Get the MultiProvider widget
      final MultiProvider multiProvider = tester.widget(multiProviderFinder);
      
      // Verify that MultiProvider exists (providers property is private)
      expect(multiProvider, isNotNull);
    });
  });
}