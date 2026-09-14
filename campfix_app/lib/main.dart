import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'screens/common/component_showcase_screen.dart';

void main() {
  runApp(const CampFixApp());
}

class CampFixApp extends StatelessWidget {
  const CampFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // dark mode toggle wired in a later phase
      home: const ComponentShowcaseScreen(),
    );
  }
}