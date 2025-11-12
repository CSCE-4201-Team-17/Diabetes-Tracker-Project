import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';

void main() async {
  //Ensures Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  //Initialize services
  await StorageService.init();
  await NotificationService.initialize();
  
  //Schedule reminders if enabled
  if (StorageService.enableReminders) {
    await NotificationService.scheduleDailyReminders();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diabetes Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
