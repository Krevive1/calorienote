import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'services/locale_service.dart';
import 'package:calorie_note/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
    return ValueListenableBuilder<Locale?>(
      valueListenable: AppLocale.current,
      builder: (context, locale, _) {
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
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}
