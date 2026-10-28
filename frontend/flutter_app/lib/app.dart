import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/dashboard/screens/dashboard_shell_screen.dart';

class SnacksOClockApp extends StatelessWidget {
  const SnacksOClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardShellScreen(),
    );
  }
}
