import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: AppRoutes.login);
    }
    final auth = Get.find<AuthController>();
    if (!auth.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
