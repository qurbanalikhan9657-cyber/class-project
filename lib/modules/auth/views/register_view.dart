import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: controller.registerFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      AppStrings.createAccount,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.signUpSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name
                    CustomTextField(
                      controller: controller.registerNameController,
                      labelText: AppStrings.fullName,
                      hintText: AppStrings.fullNameHint,
                      prefixIcon: AppIcons.user,
                      textInputAction: TextInputAction.next,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: 16),

                    // Email Address
                    CustomTextField(
                      controller: controller.registerEmailController,
                      labelText: AppStrings.email,
                      hintText: AppStrings.emailHint,
                      prefixIcon: AppIcons.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    Obx(
                      () => CustomTextField(
                        controller: controller.registerPasswordController,
                        labelText: AppStrings.password,
                        hintText: AppStrings.passwordHint,
                        prefixIcon: AppIcons.password,
                        obscureText: controller.isPasswordHidden.value,
                        textInputAction: TextInputAction.next,
                        validator: controller.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? AppIcons.visibilityOff
                                : AppIcons.visibility,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    Obx(
                      () => CustomTextField(
                        controller: controller.registerConfirmPasswordController,
                        labelText: AppStrings.confirmPassword,
                        hintText: AppStrings.confirmPasswordHint,
                        prefixIcon: AppIcons.password,
                        obscureText: controller.isConfirmPasswordHidden.value,
                        textInputAction: TextInputAction.done,
                        validator: controller.validateConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordHidden.value
                                ? AppIcons.visibilityOff
                                : AppIcons.visibility,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Register Button
                    Obx(
                      () => CustomButton(
                        text: AppStrings.signUp,
                        isLoading: controller.isRegisterLoading.value,
                        onPressed: controller.register,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Already have an account? Sign in
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppStrings.alreadyHaveAccount,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.offNamed(Routes.LOGIN),
                          child: const Text(
                            AppStrings.login,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
