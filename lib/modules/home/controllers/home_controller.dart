import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/task_service.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

enum TaskFilter { all, pending, completed }
enum TaskSort { dueDate, priority, newest }

class HomeController extends GetxController {
  final AuthService _authService = AuthService.to;
  final TaskService _taskService = TaskService.to;

  final TextEditingController searchController = TextEditingController();

  // Reactive State
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<TaskFilter> currentFilter = TaskFilter.all.obs;
  final Rx<TaskSort> currentSort = TaskSort.dueDate.obs;
  final RxString searchQuery = ''.obs;

  // Current User
  UserModel? get currentUser => _authService.currentUser;

  // Counts & Statistics
  int get totalTasksCount => tasks.length;
  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
  int get pendingTasksCount => tasks.where((t) => !t.isCompleted).length;

  double get completionRate {
    if (totalTasksCount == 0) return 0.0;
    return completedTasksCount / totalTasksCount;
  }

  // Filtered & Sorted Tasks
  List<TaskModel> get filteredTasks {
    List<TaskModel> list = List.from(tasks);

    // 1. Filter by Status
    switch (currentFilter.value) {
      case TaskFilter.pending:
        list = list.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.completed:
        list = list.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.all:
        break;
    }

    // 2. Filter by Search Query
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      list = list.where((t) =>
        t.title.toLowerCase().contains(query) ||
        t.description.toLowerCase().contains(query)
      ).toList();
    }

    // 3. Sort
    switch (currentSort.value) {
      case TaskSort.priority:
        list.sort((a, b) {
          // High (2) -> Medium (1) -> Low (0)
          final priorityWeight = {
            TaskPriority.high: 3,
            TaskPriority.medium: 2,
            TaskPriority.low: 1,
          };
          final pA = priorityWeight[a.priority] ?? 0;
          final pB = priorityWeight[b.priority] ?? 0;
          if (pB != pA) return pB.compareTo(pA);
          return a.dueDate.compareTo(b.dueDate);
        });
        break;
      case TaskSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSort.dueDate:
        list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
    }

    return list;
  }

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  /// Load tasks belonging exclusively to current user
  Future<void> loadTasks() async {
    final user = currentUser;
    if (user == null || user.id == null) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    try {
      isLoading.value = true;
      final userTasks = await _taskService.getTasksByUser(user.id!);
      tasks.assignAll(userTasks);
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to load tasks: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle completion status
  Future<void> toggleTaskStatus(TaskModel task) async {
    if (task.id == null || currentUser?.id == null) return;
    final newStatus = !task.isCompleted;

    try {
      final success = await _taskService.toggleTaskStatus(
        task.id!,
        newStatus,
        currentUser!.id!,
      );

      if (success) {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          tasks[index] = task.copyWith(isCompleted: newStatus);
        }
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Could not update task status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  /// Delete task with confirmation dialog
  Future<void> deleteTask(TaskModel task) async {
    if (task.id == null || currentUser?.id == null) return;

    ConfirmationDialog.show(
      title: AppStrings.deleteTask,
      message: AppStrings.deleteTaskConfirm,
      confirmText: 'Delete',
      confirmColor: AppColors.error,
      icon: Icons.delete_forever_rounded,
      onConfirm: () async {
        try {
          final success = await _taskService.deleteTask(task.id!, currentUser!.id!);
          if (success) {
            tasks.removeWhere((t) => t.id == task.id);
            Get.snackbar(
              'Task Deleted',
              'Task "${task.title}" has been deleted.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.secondary,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        } catch (e) {
          Get.snackbar(
            AppStrings.error,
            'Failed to delete task',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  /// Set filter tab
  void setFilter(TaskFilter filter) {
    currentFilter.value = filter;
  }

  /// Set sort option
  void setSort(TaskSort sort) {
    currentSort.value = sort;
  }

  /// Update search query
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  /// Confirm and Logout
  void logout() {
    ConfirmationDialog.show(
      title: AppStrings.logout,
      message: AppStrings.logoutConfirmation,
      confirmText: 'Log Out',
      confirmColor: AppColors.error,
      icon: Icons.logout_rounded,
      onConfirm: () async {
        await _authService.logout();
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }

  // Navigation
  void navigateToAddTask() async {
    final result = await Get.toNamed(Routes.ADD_TASK);
    if (result == true) {
      loadTasks();
    }
  }

  void navigateToEditTask(TaskModel task) async {
    final result = await Get.toNamed(Routes.EDIT_TASK, arguments: task);
    if (result == true) {
      loadTasks();
    }
  }

  void navigateToTaskDetail(TaskModel task) async {
    final result = await Get.toNamed(Routes.TASK_DETAIL, arguments: task);
    if (result == true) {
      loadTasks();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
