import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'database_helper.dart';
import 'firestore_service.dart';

class TaskService extends GetxService {
  static TaskService get to => Get.find();
  final FirestoreService _firestoreService = FirestoreService.instance;
  static const String _webTasksKey = 'web_tasks_list';

  List<TaskModel> _getWebTasks(SharedPreferences prefs) {
    final raw = prefs.getString(_webTasksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveWebTasks(SharedPreferences prefs, List<TaskModel> tasks) async {
    final list = tasks.map((t) => t.toMap()).toList();
    await prefs.setString(_webTasksKey, jsonEncode(list));
  }

  /// Retrieve all tasks for a specific user
  Future<List<TaskModel>> getTasksByUser(int userId) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final allTasks = _getWebTasks(prefs);
      final userTasks = allTasks.where((t) => t.userId == userId).toList();
      userTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return userTasks;
    } else {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'due_date ASC, created_at DESC',
      );

      return List.generate(maps.length, (i) => TaskModel.fromMap(maps[i]));
    }
  }

  /// Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    TaskModel created;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final allTasks = _getWebTasks(prefs);
      int maxId = 0;
      for (final t in allTasks) {
        if (t.id != null && t.id! > maxId) maxId = t.id!;
      }
      final nextId = maxId + 1;
      created = task.copyWith(id: nextId);
      allTasks.add(created);
      await _saveWebTasks(prefs, allTasks);
    } else {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert('tasks', task.toMap());
      created = task.copyWith(id: id);
    }
    _firestoreService.syncTask(created);
    return created;
  }

  /// Update an existing task ensuring user ownership
  Future<bool> updateTask(TaskModel task) async {
    if (task.id == null) return false;
    bool success = false;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final allTasks = _getWebTasks(prefs);
      final index = allTasks.indexWhere((t) => t.id == task.id && t.userId == task.userId);
      if (index != -1) {
        allTasks[index] = task;
        await _saveWebTasks(prefs, allTasks);
        success = true;
      }
    } else {
      final db = await DatabaseHelper.instance.database;
      final rowsAffected = await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ? AND user_id = ?',
        whereArgs: [task.id, task.userId],
      );
      success = rowsAffected > 0;
    }
    if (success) {
      _firestoreService.syncTask(task);
    }
    return success;
  }

  /// Toggle task completion status
  Future<bool> toggleTaskStatus(int taskId, bool isCompleted, int userId) async {
    bool success = false;
    TaskModel? updatedTask;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final allTasks = _getWebTasks(prefs);
      final index = allTasks.indexWhere((t) => t.id == taskId && t.userId == userId);
      if (index != -1) {
        updatedTask = allTasks[index].copyWith(isCompleted: isCompleted);
        allTasks[index] = updatedTask;
        await _saveWebTasks(prefs, allTasks);
        success = true;
      }
    } else {
      final db = await DatabaseHelper.instance.database;
      final rowsAffected = await db.update(
        'tasks',
        {'is_completed': isCompleted ? 1 : 0},
        where: 'id = ? AND user_id = ?',
        whereArgs: [taskId, userId],
      );
      success = rowsAffected > 0;
      if (success) {
        final List<Map<String, dynamic>> maps = await db.query(
          'tasks',
          where: 'id = ? AND user_id = ?',
          whereArgs: [taskId, userId],
          limit: 1,
        );
        if (maps.isNotEmpty) {
          updatedTask = TaskModel.fromMap(maps.first);
        }
      }
    }
    if (success && updatedTask != null) {
      _firestoreService.syncTask(updatedTask);
    }
    return success;
  }

  /// Delete a task ensuring user ownership
  Future<bool> deleteTask(int taskId, int userId) async {
    bool success = false;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final allTasks = _getWebTasks(prefs);
      final initialLength = allTasks.length;
      allTasks.removeWhere((t) => t.id == taskId && t.userId == userId);
      if (allTasks.length < initialLength) {
        await _saveWebTasks(prefs, allTasks);
        success = true;
      }
    } else {
      final db = await DatabaseHelper.instance.database;
      final rowsAffected = await db.delete(
        'tasks',
        where: 'id = ? AND user_id = ?',
        whereArgs: [taskId, userId],
      );
      success = rowsAffected > 0;
    }
    if (success) {
      _firestoreService.deleteTask(taskId, userId);
    }
    return success;
  }
}
