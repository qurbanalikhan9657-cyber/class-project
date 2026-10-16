import 'package:get/get.dart';
import '../models/task_model.dart';
import 'database_helper.dart';
import 'firestore_service.dart';

class TaskService extends GetxService {
  static TaskService get to => Get.find();
  final FirestoreService _firestoreService = FirestoreService.instance;

  /// Retrieve all tasks for a specific user
  Future<List<TaskModel>> getTasksByUser(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'due_date ASC, created_at DESC',
    );

    return List.generate(maps.length, (i) => TaskModel.fromMap(maps[i]));
  }

  /// Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('tasks', task.toMap());
    final created = task.copyWith(id: id);
    _firestoreService.syncTask(created);
    return created;
  }

  /// Update an existing task ensuring user ownership
  Future<bool> updateTask(TaskModel task) async {
    if (task.id == null) return false;
    final db = await DatabaseHelper.instance.database;
    final rowsAffected = await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [task.id, task.userId],
    );
    if (rowsAffected > 0) {
      _firestoreService.syncTask(task);
    }
    return rowsAffected > 0;
  }

  /// Toggle task completion status
  Future<bool> toggleTaskStatus(int taskId, bool isCompleted, int userId) async {
    final db = await DatabaseHelper.instance.database;
    final rowsAffected = await db.update(
      'tasks',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ? AND user_id = ?',
      whereArgs: [taskId, userId],
    );
    if (rowsAffected > 0) {
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'id = ? AND user_id = ?',
        whereArgs: [taskId, userId],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        _firestoreService.syncTask(TaskModel.fromMap(maps.first));
      }
    }
    return rowsAffected > 0;
  }

  /// Delete a task ensuring user ownership
  Future<bool> deleteTask(int taskId, int userId) async {
    final db = await DatabaseHelper.instance.database;
    final rowsAffected = await db.delete(
      'tasks',
      where: 'id = ? AND user_id = ?',
      whereArgs: [taskId, userId],
    );
    if (rowsAffected > 0) {
      _firestoreService.deleteTask(taskId, userId);
    }
    return rowsAffected > 0;
  }
}
