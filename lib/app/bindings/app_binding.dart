import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/task_service.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/tasks/controllers/task_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<TaskService>(() => TaskService(), fenix: true);
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskController>(() => TaskController());
  }
}
