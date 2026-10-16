import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/models/user_model.dart';
import 'package:todo_app/shared/widgets/custom_button.dart';
import 'package:todo_app/shared/widgets/custom_text_field.dart';
import 'package:todo_app/shared/widgets/task_card.dart';

void main() {
  group('UserModel Unit Tests', () {
    test('UserModel serialization and deserialization', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        passwordHash: 'hash123456',
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'John Doe');
      expect(map['email'], 'john@example.com');
      expect(map['password_hash'], 'hash123456');

      final deserialized = UserModel.fromMap(map);
      expect(deserialized.id, user.id);
      expect(deserialized.name, user.name);
      expect(deserialized.email, user.email);
      expect(deserialized.passwordHash, user.passwordHash);
    });

    test('UserModel copyWith works correctly', () {
      final user = UserModel(
        id: 1,
        name: 'Original Name',
        email: 'original@example.com',
        passwordHash: 'hash',
      );

      final updated = user.copyWith(name: 'Updated Name');
      expect(updated.name, 'Updated Name');
      expect(updated.email, 'original@example.com');
      expect(updated.id, 1);
    });
  });

  group('TaskModel Unit Tests', () {
    test('TaskModel serialization and deserialization', () {
      final dueDate = DateTime(2026, 12, 31);
      final task = TaskModel(
        id: 10,
        userId: 1,
        title: 'Complete Lab Task',
        description: 'Implement MVC, GetX, and SQLite in Flutter',
        dueDate: dueDate,
        priority: TaskPriority.high,
        isCompleted: false,
      );

      final map = task.toMap();
      expect(map['id'], 10);
      expect(map['user_id'], 1, reason: 'Task must be associated with user_id');
      expect(map['title'], 'Complete Lab Task');
      expect(map['priority'], 'high');
      expect(map['is_completed'], 0);

      final deserialized = TaskModel.fromMap(map);
      expect(deserialized.id, 10);
      expect(deserialized.userId, 1);
      expect(deserialized.title, task.title);
      expect(deserialized.priority, TaskPriority.high);
      expect(deserialized.isCompleted, false);
    });

    test('TaskPriority displayName and parsing', () {
      expect(TaskPriority.fromString('high'), TaskPriority.high);
      expect(TaskPriority.fromString('medium'), TaskPriority.medium);
      expect(TaskPriority.fromString('low'), TaskPriority.low);
      expect(TaskPriority.fromString('invalid'), TaskPriority.low);

      expect(TaskPriority.high.displayName, 'High');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.low.displayName, 'Low');
    });

    test('TaskModel overdue logic', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final futureDate = DateTime.now().add(const Duration(days: 5));

      final overdueTask = TaskModel(
        userId: 1,
        title: 'Past Task',
        description: 'Should be overdue',
        dueDate: pastDate,
        isCompleted: false,
      );

      final futureTask = TaskModel(
        userId: 1,
        title: 'Future Task',
        description: 'Not overdue',
        dueDate: futureDate,
        isCompleted: false,
      );

      final completedPastTask = TaskModel(
        userId: 1,
        title: 'Completed Past Task',
        description: 'Not overdue because completed',
        dueDate: pastDate,
        isCompleted: true,
      );

      expect(overdueTask.isOverdue, isTrue);
      expect(futureTask.isOverdue, isFalse);
      expect(completedPastTask.isOverdue, isFalse);
    });
  });

  group('Reusable Shared Widgets Tests', () {
    testWidgets('CustomButton renders text and triggers callback', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Submit Task',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Submit Task'), findsOneWidget);
      await tester.tap(find.text('Submit Task'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('CustomButton shows loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Save',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CustomTextField renders label and hint', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              labelText: 'Email Address',
              hintText: 'Enter your email',
            ),
          ),
        ),
      );

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(controller.text, 'test@example.com');
    });

    testWidgets('TaskCard renders task info and priority badge', (WidgetTester tester) async {
      final task = TaskModel(
        id: 1,
        userId: 1,
        title: 'Submit Lab Report',
        description: 'Include MVC screenshots',
        dueDate: DateTime(2026, 10, 20),
        priority: TaskPriority.high,
        isCompleted: false,
      );

      bool cardTapped = false;
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: task,
              onTap: () {
                cardTapped = true;
              },
              onToggleComplete: (val) {
                toggled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Submit Lab Report'), findsOneWidget);
      expect(find.text('Include MVC screenshots'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);

      // Tap on the checkbox icon (inner InkWell) to toggle
      await tester.tap(find.byType(InkWell).last);
      await tester.pump();
      expect(toggled, isTrue);

      // Tap on the outer card InkWell
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(cardTapped, isTrue);
    });
  });
}
