import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/theme/app_theme.dart';
import 'package:gsma/routes/app_pages.dart';

class GsmaApp extends StatelessWidget {
  const GsmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppTheme.appTitle(),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
