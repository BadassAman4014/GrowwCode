import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'H2.dart';
import 'Homepage.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'login/Authentication/phone_auth_provider.dart';
import 'login/splashscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:growwcode/language_provider.dart'; // Import the LanguageProvider

void main() async {
  AwesomeNotifications().initialize(
    null,
    [NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
    )],
    debug: true,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Provide AuthProvider
        ChangeNotifierProvider(create: (_) => LanguageProvider()), // Provide LanguageProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          locale: languageProvider.locale,
          supportedLocales: [
            Locale('en'),
            Locale('hi'), // Add other languages
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: HomeScreen(language: languageProvider.locale.languageCode),
        );
      },
    );
  }

}



