// lib/route/app_routes.dart
import 'package:flutter/material.dart';
import '../screen/splashscreen.dart';
import '../screen/beranda.dart';
import '../screen/bookmark.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String beranda = '/beranda';
  static const String bookmark = '/bookmark';
  static const String search = '/search';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      beranda: (context) => const HomeScreen(),
      bookmark: (context) => const BookmarkScreen(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case home:
      case beranda:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case bookmark:
        return MaterialPageRoute(builder: (context) => const BookmarkScreen());
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