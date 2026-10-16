import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/bindings/app_binding.dart';
import 'app/constants/app_colors.dart';
import 'app/constants/app_strings.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'data/services/auth_service.dart';
import 'data/services/task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with project class-project-55319
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Initialize core services before running the app
  await Get.putAsync<AuthService>(() => AuthService().init());
  Get.put<TaskService>(TaskService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine start route dynamically based on active session
    final authService = AuthService.to;
    final initialRoute = authService.isAuthenticated ? Routes.HOME : Routes.LOGIN;

    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      initialBinding: AppBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
