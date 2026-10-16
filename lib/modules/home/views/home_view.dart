import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/task_card.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadTasks,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Dashboard Cards
                _buildStatisticsDashboard(),
                const SizedBox(height: 20),

                // Search Bar
                _buildSearchBar(),
                const SizedBox(height: 16),

                // Filters and Sorting Toolbar
                _buildFilterAndSortRow(),
                const SizedBox(height: 16),

                // Task List Section
                _buildTaskList(),
                const SizedBox(height: 80), // Padding for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.navigateToAddTask,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(AppIcons.add, color: Colors.white),
        label: const Text(
          'Add Task',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Obx(() {
        final userName = controller.currentUser?.name ?? 'User';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName 👋',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Manage your daily tasks',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          tooltip: AppStrings.logout,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.priorityHighBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              AppIcons.logout,
              color: AppColors.priorityHigh,
              size: 20,
            ),
          ),
          onPressed: controller.logout,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatisticsDashboard() {
    return Obx(() {
      final total = controller.totalTasksCount;
      final completed = controller.completedTasksCount;
      final pending = controller.pendingTasksCount;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatCard(
                  title: AppStrings.total,
                  count: total.toString(),
                  icon: AppIcons.totalTasks,
                  color: AppColors.primary,
                  bgColor: AppColors.primaryLight.withValues(alpha: 0.12),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: AppStrings.inProgress,
                  count: pending.toString(),
                  icon: AppIcons.pendingTasks,
                  color: AppColors.pending,
                  bgColor: AppColors.pendingBg,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: AppStrings.done,
                  count: completed.toString(),
                  icon: AppIcons.completedTasks,
                  color: AppColors.completed,
                  bgColor: AppColors.completedBg,
                ),
              ],
            ),
            if (total > 0) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: controller.completionRate,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.completed),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(controller.completionRate * 100).toInt()}% Tasks Completed',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: AppStrings.searchTasks,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
          ),
          prefixIcon: const Icon(
            AppIcons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(AppIcons.close, size: 18, color: AppColors.textSecondary),
                onPressed: controller.clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterAndSortRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Filter Tabs
            Obx(
              () => Row(
                children: [
                  _buildFilterChip('All', TaskFilter.all),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', TaskFilter.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', TaskFilter.completed),
                ],
              ),
            ),

            // Sort Dropdown
            Obx(
              () => PopupMenuButton<TaskSort>(
                initialValue: controller.currentSort.value,
                onSelected: controller.setSort,
                tooltip: 'Sort tasks',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(AppIcons.sort, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _sortLabel(controller.currentSort.value),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: TaskSort.dueDate,
                    child: Text('Sort by Due Date'),
                  ),
                  const PopupMenuItem(
                    value: TaskSort.priority,
                    child: Text('Sort by Priority'),
                  ),
                  const PopupMenuItem(
                    value: TaskSort.newest,
                    child: Text('Sort by Newest'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _sortLabel(TaskSort sort) {
    switch (sort) {
      case TaskSort.priority:
        return 'Priority';
      case TaskSort.newest:
        return 'Newest';
      case TaskSort.dueDate:
        return 'Due Date';
    }
  }

  Widget _buildFilterChip(String label, TaskFilter filter) {
    final isSelected = controller.currentFilter.value == filter;
    return GestureDetector(
      onTap: () => controller.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: LoadingWidget(message: 'Loading tasks...'),
        );
      }

      final tasks = controller.filteredTasks;

      if (tasks.isEmpty) {
        final isSearching = controller.searchQuery.value.isNotEmpty;
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.task,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isSearching ? 'No Matching Tasks' : AppStrings.noTasksFound,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSearching
                      ? AppStrings.noMatchingTasks
                      : AppStrings.noTasksSub,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => controller.navigateToTaskDetail(task),
            onToggleComplete: (_) => controller.toggleTaskStatus(task),
            onEdit: () => controller.navigateToEditTask(task),
            onDelete: () => controller.deleteTask(task),
          );
        },
      );
    });
  }
}
