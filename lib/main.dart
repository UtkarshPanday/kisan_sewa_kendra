import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';

import 'controller/constants.dart';
import 'firebase_options.dart';
import 'utils/meta_events.dart';
import 'utils/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controller/language_controller.dart';
import 'view/splash_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.firebaseMessagingBackgroundHandler(message);
}

//this is the dev branch
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Environment Variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Dotenv loading error: $e");
  }

  try {
    // Firebase Init
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Activate App Check
    // AndroidProvider.debug is useful for testing on emulators
    // AndroidProvider.playIntegrity is for production
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );

    // Initialize Push Notifications
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationService.init();

    // Initialize Meta Events
    await MetaEvents.init();

    final languageController = LanguageController();
    Constants.languageController = languageController;

    runApp(MyApp(languageController: languageController));
// ignore: strict_top_level_inference
  } catch (e) {
    debugPrint("Error: $e");
  }
}

class MyApp extends StatelessWidget {
  final LanguageController languageController;
  const MyApp({super.key, required this.languageController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageController,
      builder: (context, child) {
        return MaterialApp(
          title: Constants.title,
          debugShowCheckedModeBanner: false,
          locale: languageController.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('te'),
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Constants.baseColor),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            textTheme: GoogleFonts.interTextTheme().copyWith(
              displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w900),
              displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.w800),
              displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.w800),
              headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.w800),
              headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Constants.baseColor,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              elevation: 10,
              type: BottomNavigationBarType.fixed,
            ),
            cardTheme: const CardThemeData(
              elevation: 5,
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            appBarTheme: AppBarTheme(
              foregroundColor: Constants.baseColor,
              backgroundColor: Colors.white,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
