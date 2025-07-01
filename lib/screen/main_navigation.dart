import 'package:flutter/material.dart';
import 'beranda.dart';
import 'bookmark.dart';
import 'profil.dart';
import 'search.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();

  // Static methods if needed
  static void navigateToSearch(BuildContext context) {
    final state = context.findAncestorStateOfType<_MainNavigationState>();
    state?.onTabTapped(1);
  }

  static void navigateToBookmark(BuildContext context) {
    final state = context.findAncestorStateOfType<_MainNavigationState>();
    state?.onTabTapped(2);
  }

  static void navigateToProfile(BuildContext context) {
    final state = context.findAncestorStateOfType<_MainNavigationState>();
    state?.onTabTapped(3);
  }
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    BookmarkScreen(),
    ProfileScreen(),
  ];

  void onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
