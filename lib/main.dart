import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_helper.dart';
import 'res/values/strings.dart';
import 'res/values/styles.dart';
import 'session_store.dart';
import 'ui/home_activity.dart';
import 'ui/login_activity.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationHelper.init();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize persistent SessionStore
  final sessionStore = SessionStore.instance;
  await sessionStore.init();

  sessionStore.onSessionExpired = () {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginActivity()),
      (route) => false,
    );
  };

  runApp(const VietSageHousekeepingApp());
}

class VietSageHousekeepingApp extends StatelessWidget {
  const VietSageHousekeepingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.instance;

    return MaterialApp(
      title: ResStrings.appName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ResStyles.lightTheme,
      home: session.isLoggedIn ? const HomeActivity() : const LoginActivity(),
    );
  }
}
