import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/transaction_model.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  await Hive.openBox<TransactionModel>('transactions');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // null = follow system, true = forced dark, false = forced light
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      // If currently following system, check what system is and flip from there
      final systemIsDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;

      if (_themeMode == ThemeMode.system) {
        // Break away from system: flip to opposite of current system
        _themeMode = systemIsDark ? ThemeMode.light : ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spendly',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode, // system = auto follow phone theme
      home: DashboardScreen(toggleTheme: toggleTheme),
    );
  }
}
