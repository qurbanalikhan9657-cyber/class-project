import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_strings.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/task_service.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

class TaskController extends GetxController {
  final TaskService _taskService = TaskService.to;
  final AuthService _authService = AuthService.to;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Reactive Task State
  final Rx<DateTime> selectedDueDate = DateTime.now().obs;
  final Rx<TaskPriority> selectedPriority = TaskPriority.medium.obs;
  final RxBool isCompleted = false.obs;
  final RxBool isLoading = false.obs;

  TaskModel? existingTask;
  bool get isEditing => existingTask != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is TaskModel) {
      existingTask = args;
      titleController.text = args.title;
      descriptionController.text = args.description;
      selectedDueDate.value = args.dueDate;
      selectedPriority.value = args.priority;
      isCompleted.value = args.isCompleted;
    }
  }

  /// Title Validator
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.titleRequired;
    }
    return null;
  }

  /// Change Priority
  void setPriority(TaskPriority priority) {
    selectedPriority.value = priority;
  }

  /// Pick Due Date via DatePicker
  Future<void> pickDueDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      selectedDueDate.value = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        selectedDueDate.value.hour,
        selectedDueDate.value.minute,
      );
    }
  }

  /// Save or Update Task
  Future<void> saveTask() async {
    if (!formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null || user.id == null) {
      Get.snackbar(
        AppStrings.error,
        'User authentication required',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      if (isEditing) {
        final updatedTask = existingTask!.copyWith(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          dueDate: selectedDueDate.value,
          priority: selectedPriority.value,
          isCompleted: isCompleted.value,
        );

        final success = await _taskService.updateTask(updatedTask);
        if (success) {
          Get.back(result: true);
          Get.snackbar(
            AppStrings.success,
            'Task updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          );
        }
      } else {
        final newTask = TaskModel(
          userId: user.id!,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          dueDate: selectedDueDate.value,
          priority: selectedPriority.value,
          isCompleted: false,
        );

        await _taskService.createTask(newTask);
        Get.back(result: true);
        Get.snackbar(
          AppStrings.success,
          'Task created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to save task: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle completion on detail screen
  Future<void> toggleCompletion() async {
    if (existingTask == null || _authService.currentUser?.id == null) return;
    final newStatus = !isCompleted.value;

    try {
      final success = await _taskService.toggleTaskStatus(
        existingTask!.id!,
        newStatus,
        _authService.currentUser!.id!,
      );

      if (success) {
        isCompleted.value = newStatus;
        existingTask = existingTask!.copyWith(isCompleted: newStatus);
        Get.snackbar(
          AppStrings.success,
          newStatus ? 'Task marked as completed' : 'Task marked as pending',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: newStatus ? AppColors.completed : AppColors.pending,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to update status',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  /// Delete task from detail screen
  Future<void> deleteTask() async {
    if (existingTask == null || _authService.currentUser?.id == null) return;

    ConfirmationDialog.show(
      title: AppStrings.deleteTask,
      message: AppStrings.deleteTaskConfirm,
      confirmText: 'Delete',
      confirmColor: AppColors.error,
      icon: Icons.delete_forever_rounded,
      onConfirm: () async {
        try {
          final success = await _taskService.deleteTask(
            existingTask!.id!,
            _authService.currentUser!.id!,
          );
          if (success) {
            Get.back(result: true); // Back from detail screen to Home
            Get.snackbar(
              'Deleted',
              'Task deleted successfully',
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
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
