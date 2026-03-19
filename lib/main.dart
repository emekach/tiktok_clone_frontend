// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';
import 'services/api_service.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/feed/feed_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/chat_detail_screen.dart';
import 'screens/calls/calls_screen.dart';
import 'screens/communities/communities_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService().init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppConstants.obsidian,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: const TikTokApp(),
    ),
  );
}

class TikTokApp extends StatelessWidget {
  const TikTokApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final status = authProvider.status;

        if (status == AuthStatus.unauthenticated &&
            !state.matchedLocation.startsWith('/auth') &&
            state.matchedLocation != '/splash') {
          return '/splash';
        }

        if (status == AuthStatus.authenticated &&
            (state.matchedLocation.startsWith('/auth') ||
                state.matchedLocation == '/splash')) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
        GoRoute(
            path: '/auth/otp',
            builder: (_, state) =>
                OtpScreen(email: state.extra as String? ?? '')),
        GoRoute(
            path: '/auth/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(
          path: '/chat/detail/:username',
          builder: (_, state) =>
              ChatDetailScreen(username: state.pathParameters['username']!),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, __) => const ChatListScreen()),
            GoRoute(path: '/updates', builder: (_, __) => const FeedScreen()),
            GoRoute(
                path: '/communities',
                builder: (_, __) => const CommunitiesScreen()),
            GoRoute(path: '/calls', builder: (_, __) => const CallsScreen()),
            GoRoute(
              path: '/profile/:username',
              builder: (_, state) => ProfileScreen(
                username: state.pathParameters['username']!,
              ),
              routes: [
                GoRoute(
                    path: 'edit',
                    builder: (_, __) => const EditProfileScreen()),
              ],
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Luxe Social',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.obsidian,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.primaryGold,
          secondary: AppConstants.accentRose,
          surface: AppConstants.surfaceDark,
          background: AppConstants.obsidian,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppConstants.primaryGold,
              letterSpacing: -1),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      routerConfig: router,
    );
  }
}
