import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/task_controller.dart';

class TaskDetailView extends GetView<TaskController> {
  const TaskDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          AppStrings.taskDetails,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.edit, color: AppColors.primary, size: 22),
            onPressed: () async {
              if (controller.existingTask != null) {
                final result = await Get.toNamed(
                  Routes.EDIT_TASK,
                  arguments: controller.existingTask,
                );
                if (result == true) {
                  Get.back(result: true); // notify Home to refresh
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(AppIcons.delete, color: AppColors.error, size: 22),
            onPressed: controller.deleteTask,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            final task = controller.existingTask;
            if (task == null) {
              return const Center(child: Text('Task not found'));
            }

            final isDone = controller.isCompleted.value;
            final isOverdue = task.isOverdue && !isDone;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status & Priority Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Indicator
                      Row(
                        children: [
                          Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : Icons.hourglass_top_rounded,
                            color: isDone ? AppColors.completed : AppColors.pending,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isDone ? 'Completed' : 'Pending',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDone ? AppColors.completed : AppColors.pending,
                            ),
                          ),
                        ],
                      ),

                      // Priority Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: task.priority.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(AppIcons.flag, size: 14, color: task.priority.color),
                            const SizedBox(width: 4),
                            Text(
                              '${task.priority.displayName} Priority',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: task.priority.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Main Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDone ? AppColors.textLight : AppColors.textPrimary,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 12),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.description.isNotEmpty
                            ? task.description
                            : 'No description provided.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: task.description.isNotEmpty
                              ? AppColors.textPrimary
                              : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 12),

                      // Due Date Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              AppIcons.calendar,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Due Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                task.formattedDueDate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          if (isOverdue) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.priorityHighBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Overdue',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.priorityHigh,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Created Date Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              AppIcons.clock,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Created On',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMM d, yyyy - hh:mm a').format(task.createdAt),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Toggle Completion Button
                CustomButton(
                  text: isDone ? 'Mark as Pending' : 'Mark as Completed',
                  icon: isDone ? Icons.hourglass_empty_rounded : Icons.check_circle_outline_rounded,
                  backgroundColor: isDone ? AppColors.pending : AppColors.completed,
                  onPressed: controller.toggleCompletion,
                ),
                const SizedBox(height: 12),

                // Edit Button
                CustomButton(
                  text: 'Edit Details',
                  icon: AppIcons.edit,
                  isOutlined: true,
                  backgroundColor: AppColors.primary,
                  onPressed: () async {
                    final result = await Get.toNamed(
                      Routes.EDIT_TASK,
                      arguments: controller.existingTask,
                    );
                    if (result == true) {
                      Get.back(result: true);
                    }
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
