import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/task_controller.dart';

class AddEditTaskView extends GetView<TaskController> {
  const AddEditTaskView({super.key});

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
        title: Text(
          controller.isEditing ? AppStrings.editTask : AppStrings.addTask,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                CustomTextField(
                  controller: controller.titleController,
                  labelText: AppStrings.taskTitle,
                  hintText: AppStrings.taskTitleHint,
                  prefixIcon: AppIcons.title,
                  validator: controller.validateTitle,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Description Field
                CustomTextField(
                  controller: controller.descriptionController,
                  labelText: AppStrings.taskDescription,
                  hintText: AppStrings.taskDescriptionHint,
                  prefixIcon: AppIcons.description,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),

                // Due Date Selector
                const Text(
                  AppStrings.dueDate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final formatted = DateFormat('EEE, MMM d, yyyy').format(
                    controller.selectedDueDate.value,
                  );
                  return InkWell(
                    onTap: () => controller.pickDueDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            AppIcons.calendar,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatted,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Priority Selector
                const Text(
                  AppStrings.priority,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  return Row(
                    children: TaskPriority.values.map((priority) {
                      final isSelected = controller.selectedPriority.value == priority;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.setPriority(priority),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? priority.color
                                  : priority.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? priority.color
                                    : priority.color.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: priority.color.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  AppIcons.flag,
                                  size: 16,
                                  color: isSelected ? Colors.white : priority.color,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  priority.displayName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : priority.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 24),

                // Completion Status (if Editing)
                if (controller.isEditing) ...[
                  Obx(() {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                controller.isCompleted.value
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: controller.isCompleted.value
                                    ? AppColors.completed
                                    : AppColors.textSecondary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                controller.isCompleted.value
                                    ? 'Status: Completed'
                                    : 'Status: Pending',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: controller.isCompleted.value,
                            activeThumbColor: AppColors.completed,
                            onChanged: (val) => controller.isCompleted.value = val,
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 28),
                ],

                // Submit Button
                Obx(
                  () => CustomButton(
                    text: controller.isEditing
                        ? AppStrings.updateTask
                        : AppStrings.saveTask,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.saveTask,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
