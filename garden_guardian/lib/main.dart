// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/system_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/home_screen.dart';
import 'screens/alert_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/known_cats_screen.dart';
import 'screens/event_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase init (uncomment after adding google-services.json / GoogleService-Info.plist) ──
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SystemProvider()),
      ],
      child: const GardenGuardianApp(),
    ),
  );
}

// ──────────────────────────────────────────────────────────
//  Router
// ──────────────────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(path: '/home',          builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/camera',        builder: (_, __) => const CameraScreen()),
        GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
        GoRoute(path: '/settings',      builder: (_, __) => const SettingsScreen()),
      ],
    ),
    // Full-screen routes (no bottom nav)
    GoRoute(path: '/alert',          builder: (_, __) => const AlertScreen()),
    GoRoute(path: '/known-cats',     builder: (_, __) => const KnownCatsScreen()),
    GoRoute(
      path: '/event/:id',
      builder: (_, state) => EventDetailScreen(eventId: state.pathParameters['id']!),
    ),
  ],
);

// ──────────────────────────────────────────────────────────
//  Root App Widget
// ──────────────────────────────────────────────────────────
class GardenGuardianApp extends StatelessWidget {
  const GardenGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title:                'Garden Guardian',
      theme:                AppTheme.theme,
      routerConfig:         _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
