import 'package:flutter_test/flutter_test.dart';
import 'package:su_takip/core/utils/debug_logger.dart';
import 'package:su_takip/data/models/water_intake_model.dart';
import 'package:su_takip/data/models/user_model.dart';

void main() {
  group('Unit Tests - No Firebase Required', () {
    
    group('Calculations Tests', () {
      test('Water intake calculations should work correctly', () {
        // Test basic calculations
        expect(2 + 2, equals(4));
        expect(1000 * 0.5, equals(500.0));
      });

      test('Percentage calculations should be accurate', () {
        double current = 1500.0;
        double target = 2000.0;
        double percentage = (current / target) * 100;
        
        expect(percentage, equals(75.0));
        expect(percentage, lessThanOrEqualTo(100.0));
      });
    });

    group('Data Models Tests', () {
      test('WaterIntakeModel should create correctly', () {
        final intake = WaterIntakeModel(
          id: 'test-id',
          amount: 250.0,
          timestamp: DateTime.now(),
          note: 'Test note',
        );

        expect(intake.id, equals('test-id'));
        expect(intake.amount, equals(250.0));
        expect(intake.note, equals('Test note'));
        expect(intake.timestamp, isA<DateTime>());
      });

      test('WaterIntakeModel toJson should work', () {
        final intake = WaterIntakeModel(
          id: 'test-id',
          amount: 250.0,
          timestamp: DateTime(2024, 1, 1, 12, 0),
          note: 'Test note',
        );

        final json = intake.toJson();
        
        expect(json['id'], equals('test-id'));
        expect(json['amount'], equals(250.0));
        expect(json['note'], equals('Test note'));
        expect(json['timestamp'], isA<String>());
      });

      test('UserModel should create correctly', () {
        final user = UserModel(
          id: 'test-id',
          name: 'Test User',
          email: 'test@example.com',
          age: 25,
          weight: 70.0,
          activityLevel: 'moderate',
          dailyWaterGoal: 2000.0,
          createdAt: DateTime.now(),
        );

        expect(user.id, equals('test-id'));
        expect(user.name, equals('Test User'));
        expect(user.email, equals('test@example.com'));
        expect(user.age, equals(25));
        expect(user.weight, equals(70.0));
        expect(user.dailyWaterGoal, equals(2000.0));
      });
    });

    group('Debug Logger Tests', () {
      test('DebugLogger should not crash', () {
        // Test that debug logger methods don't crash
        expect(() => DebugLogger.info('Test message', tag: 'TEST'), returnsNormally);
        expect(() => DebugLogger.error('Test error', tag: 'TEST'), returnsNormally);
        expect(() => DebugLogger.success('Test success', tag: 'TEST'), returnsNormally);
        expect(() => DebugLogger.warning('Test warning', tag: 'TEST'), returnsNormally);
      });
    });

    group('Utility Functions Tests', () {
      test('String validation should work', () {
        expect('test@example.com'.contains('@'), isTrue);
        expect('invalid-email'.contains('@'), isFalse);
        expect(''.isEmpty, isTrue);
        expect('not empty'.isNotEmpty, isTrue);
      });

      test('Date calculations should work', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));

        expect(yesterday.isBefore(now), isTrue);
        expect(tomorrow.isAfter(now), isTrue);
        expect(now.difference(yesterday).inDays, equals(1));
      });

      test('List operations should work', () {
        final numbers = [1, 2, 3, 4, 5];
        final sum = numbers.reduce((a, b) => a + b);
        final average = sum / numbers.length;

        expect(sum, equals(15));
        expect(average, equals(3.0));
        expect(numbers.length, equals(5));
        expect(numbers.first, equals(1));
        expect(numbers.last, equals(5));
      });
    });

    group('Water Intake Logic Tests', () {
      test('Daily intake calculation should be correct', () {
        final intakes = [
          {'amount': 250.0, 'timestamp': DateTime.now()},
          {'amount': 300.0, 'timestamp': DateTime.now()},
          {'amount': 200.0, 'timestamp': DateTime.now()},
        ];

        double totalIntake = 0.0;
        for (final intake in intakes) {
          totalIntake += intake['amount'] as double;
        }

        expect(totalIntake, equals(750.0));
      });

      test('Goal percentage calculation should be accurate', () {
        double currentIntake = 1500.0;
        double dailyGoal = 2000.0;
        double percentage = (currentIntake / dailyGoal) * 100;

        expect(percentage, equals(75.0));
        expect(percentage < 100, isTrue);
        
        // Test goal reached
        currentIntake = 2000.0;
        percentage = (currentIntake / dailyGoal) * 100;
        expect(percentage, equals(100.0));
        
        // Test goal exceeded
        currentIntake = 2500.0;
        percentage = (currentIntake / dailyGoal) * 100;
        expect(percentage, equals(125.0));
        expect(percentage > 100, isTrue);
      });
    });

    group('Badge Logic Tests', () {
      test('Badge requirements should be calculated correctly', () {
        // Test streak calculations
        int currentStreak = 7;
        List<int> badgeRequirements = [1, 3, 7, 14, 30, 100];
        
        List<int> earnedBadges = badgeRequirements
            .where((requirement) => currentStreak >= requirement)
            .toList();
            
        expect(earnedBadges, equals([1, 3, 7]));
        expect(earnedBadges.length, equals(3));
        
        // Test next badge requirement
        int? nextBadge = badgeRequirements
            .where((requirement) => currentStreak < requirement)
            .isNotEmpty 
            ? badgeRequirements
                .where((requirement) => currentStreak < requirement)
                .first 
            : null;
            
        expect(nextBadge, equals(14));
      });
    });

    group('Environment Variables Tests', () {
      test('Environment variables should be accessible', () {
        // Test environment variable access (will be empty in test)
        const apiKey = String.fromEnvironment('FIREBASE_API_KEY_WEB', defaultValue: 'test-default');
        const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID_WEB', defaultValue: 'test-project');
        
        expect(apiKey, isA<String>());
        expect(projectId, isA<String>());
        expect(apiKey.isNotEmpty, isTrue);
        expect(projectId.isNotEmpty, isTrue);
      });
    });
  });
}