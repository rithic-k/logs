import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/app_lock/app_lock_screen.dart';
import 'services/security_service.dart';
import 'theme/app_theme.dart';

class DailyTrackerApp extends StatelessWidget {
  const DailyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      theme: AppTheme.darkTheme,
      home: Consumer<SecurityService>(
        builder: (context, securityService, child) {
          return const AppLockScreen();
        },
      ),
    );
  }
}
