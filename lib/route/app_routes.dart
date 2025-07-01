/*
// lib/route/app_routes.dart
import 'package:flutter/material.dart';
import '../screen/main_navigation.dart';
import '../screen/splashscreen.dart';
import '../screen/splashscreen.dart';
import '../screen/main_navigation.dart';
import '../screen/beranda.dart';
import '../screen/bookmark.dart';
import '../screen/search.dart';
import '../screen/profil.dart';

class AppRoutes {
  static const String splash = '/';
  static const String main = '/main';
  static const String home = '/home';
  static const String beranda = '/beranda';
  static const String bookmark = '/bookmark';
  static const String search = '/search';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      main: (context) => const MainNavigation(initialIndex: 0),
      home: (context) => const MainNavigation(initialIndex: 0),
      beranda: (context) => const MainNavigation(initialIndex: 0),
      search: (context) => const MainNavigation(initialIndex: 1), // Search tab
      bookmark: (context) => const MainNavigation(initialIndex: 2), // Bookmark tab
      profile: (context) => const MainNavigation(initialIndex: 3), // Profile tab
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case main:
      case home:
      case beranda:
        return MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 0));
      case search:
        return MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 1));
      case bookmark:
        return MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 2));
      case profile:
        return MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 3));
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('404 - Page Not Found'),
            ),
          ),
        );
    }
  }
}
*/
