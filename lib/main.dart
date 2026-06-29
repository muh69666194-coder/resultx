import 'package:flutter/material.dart';

// 🚨 RESULTX IMPORTS
import 'package:ResultX/screens/auth/login_screen.dart';
// Note: BootSplashScreen import has been permanently removed!

// 🚨 FIREBASE IMPORTS
import 'package:firebase_messaging/firebase_messaging.dart';

// 🚨 SUPABASE IMPORTS
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase configuration
const String supabaseUrl = 'MY SUPABASE URL GOES HERE';
const String supabaseAnonKey = 'MY ANON KEY GOES HERE';

// 1. GLOBAL KEY
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 2. THE "HALL PASS" (Security Bypass Flag)
bool isInteractingWithSystem = false;

// 3. THEMING NOTIFIERS
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<Color> appColorNotifier = ValueNotifier(
  const Color(0xFF007ACC),
);

// 🚨 BACKGROUND NOTIFICATION HANDLER
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

// 🚨 ADDED ASYNC
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚨 SUPABASE WAKE-UP CALL: Since the splash screen is dead, we do it here!
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached && !isInteractingWithSystem) {
      debugPrint("--- APP CLOSED: LOCKING SCREEN ---");
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return ValueListenableBuilder<Color>(
          valueListenable: appColorNotifier,
          builder: (context, currentPrimaryColor, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'ResultX School',
              themeMode: currentMode,
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: currentPrimaryColor,
                scaffoldBackgroundColor: Colors.grey[50],
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: currentPrimaryColor,
                  brightness: Brightness.light,
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: currentPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: currentPrimaryColor,
                scaffoldBackgroundColor: const Color(0xFF121212),
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: currentPrimaryColor,
                  brightness: Brightness.dark,
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: currentPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                ),
              ),

              // 🚨 THE FIX: Routing directly to your Login Screen
              home: const LoginScreen(),
            );
          },
        );
      },
    );
  }
}
