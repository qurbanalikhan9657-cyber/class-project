import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/constants/app_colors.dart';

enum TaskPriority {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TaskPriority.low:
        return AppColors.priorityLowBg;
      case TaskPriority.medium:
        return AppColors.priorityMediumBg;
      case TaskPriority.high:
        return AppColors.priorityHighBg;
    }
  }

  static TaskPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
      default:
        return TaskPriority.low;
    }
  }
}

class TaskModel {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  String get formattedDueDate {
    return DateFormat('EEE, MMM d, yyyy').format(dueDate);
  }

  String get formattedShortDueDate {
    return DateFormat('MMM d').format(dueDate);
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority.name,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      dueDate: DateTime.parse(map['due_date'] as String),
      priority: TaskPriority.fromString(map['priority'] as String),
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  TaskModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, userId: $userId, title: $title, priority: ${priority.name}, completed: $isCompleted)';
  }
}
