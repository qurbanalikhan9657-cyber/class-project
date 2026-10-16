// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/tasks/views/add_edit_task_view.dart';
import '../../modules/tasks/views/task_detail_view.dart';
import '../bindings/app_binding.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = AuthService.to;
    final isAuthenticated = authService.isAuthenticated;

    // Protected routes requiring authentication
    final protectedRoutes = [
      Routes.HOME,
      Routes.ADD_TASK,
      Routes.EDIT_TASK,
      Routes.TASK_DETAIL,
    ];

    if (!isAuthenticated && protectedRoutes.contains(route)) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    // Guest-only routes
    if (isAuthenticated && (route == Routes.LOGIN || route == Routes.REGISTER)) {
      return const RouteSettings(name: Routes.HOME);
    }

    return null;
  }
}

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.ADD_TASK,
      page: () => const AddEditTaskView(),
      binding: TaskBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.EDIT_TASK,
      page: () => const AddEditTaskView(),
      binding: TaskBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.TASK_DETAIL,
      page: () => const TaskDetailView(),
      binding: TaskBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
  ];
}
