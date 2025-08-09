import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 通知サービスを初期化
  await NotificationService.initialize();
  
  // AdMobを初期化
  await AdService.initialize();
  
  runApp(const CalorieNoteApp());
}

class CalorieNoteApp extends StatelessWidget {
  const CalorieNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'カロリーノート',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
