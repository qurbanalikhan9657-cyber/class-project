import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();
  FirestoreService._init();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _userTasksRef(int userId) {
    final db = _firestore;
    if (db == null) return null;
    return db.collection('users').doc(userId.toString()).collection('tasks');
  }

  /// Sync task record to Cloud Firestore
  Future<void> syncTask(TaskModel task) async {
    try {
      if (task.id == null) return;
      final ref = _userTasksRef(task.userId);
      if (ref == null) return;
      await ref.doc(task.id.toString()).set(task.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore task sync notice: $e');
    }
  }

  /// Delete task record from Cloud Firestore
  Future<void> deleteTask(int taskId, int userId) async {
    try {
      final ref = _userTasksRef(userId);
      if (ref == null) return;
      await ref.doc(taskId.toString()).delete();
    } catch (e) {
      debugPrint('Firestore task deletion notice: $e');
    }
  }
}
