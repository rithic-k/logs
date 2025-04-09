import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app.dart';
import 'services/security_service.dart';
import 'services/local_storage_service.dart';
import 'providers/log_provider.dart';
import 'providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  final securityService = await SecurityService.initialize();
  final storageService = await LocalStorageService.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<SecurityService>.value(value: securityService),
        Provider<LocalStorageService>.value(value: storageService),
        ChangeNotifierProvider(
          create: (context) => LogProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(storageService),
        ),
      ],
      child: const DailyTrackerApp(),
    ),
  );
}
