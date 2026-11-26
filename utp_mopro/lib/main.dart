import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/favorites_page.dart';
import 'pages/notes_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SQLite untuk semua platform (Web Chrome, Windows Desktop, Android, iOS)
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const KopiNusantaraApp());
}

class KopiNusantaraApp extends StatelessWidget {
  const KopiNusantaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kopi Nusantara',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();
  final GlobalKey<FavoritesPageState> _favoritesKey =
      GlobalKey<FavoritesPageState>();
  final GlobalKey<NotesPageState> _notesKey = GlobalKey<NotesPageState>();

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        key: _homeKey,
        onFavoritesChanged: () {
          _favoritesKey.currentState?.refreshData();
          _notesKey.currentState?.refreshData();
        },
      ),
      FavoritesPage(key: _favoritesKey),
      NotesPage(key: _notesKey),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.espresso.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.coffee_rounded,
                  label: 'Katalog',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Favorit',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.sticky_note_2_rounded,
                  label: 'Catatan',
                  index: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 0) {
          _homeKey.currentState?.refreshData();
        } else if (index == 1) {
          _favoritesKey.currentState?.refreshData();
        } else {
          _notesKey.currentState?.refreshData();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.espresso.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.espresso : AppTheme.lightRoast,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.espresso,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
