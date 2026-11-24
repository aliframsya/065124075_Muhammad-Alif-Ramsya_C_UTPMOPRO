import 'package:flutter/material.dart';

class AppTheme {
  // Color palette - warm coffee tones
  static const Color espresso = Color(0xFF2C1810);
  static const Color darkRoast = Color(0xFF3E2723);
  static const Color mediumRoast = Color(0xFF5D4037);
  static const Color lightRoast = Color(0xFF8D6E63);
  static const Color cream = Color(0xFFF5F0EB);
  static const Color warmWhite = Color(0xFFFAF8F5);
  static const Color caramel = Color(0xFFD4A574);
  static const Color gold = Color(0xFFCDA349);
  static const Color accent = Color(0xFFBF360C);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mediumRoast,
        brightness: Brightness.light,
        primary: espresso,
        secondary: caramel,
        surface: warmWhite,
        onPrimary: Colors.white,
        onSecondary: espresso,
        tertiary: accent,
      ),
      scaffoldBackgroundColor: warmWhite,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: espresso,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: espresso,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: espresso,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: espresso,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: darkRoast),
        bodyMedium: TextStyle(fontSize: 14, color: mediumRoast),
        bodySmall: TextStyle(fontSize: 12, color: lightRoast),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: espresso,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: warmWhite,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: espresso,
        ),
        iconTheme: IconThemeData(color: espresso),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cream, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cream,
        labelStyle: const TextStyle(fontSize: 12, color: mediumRoast),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(fontSize: 14, color: lightRoast),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}

class RoastLevelHelper {
  static Color getColor(String level) {
    switch (level) {
      case 'Light':
        return const Color(0xFFC8A87C);
      case 'Medium':
        return const Color(0xFF8B6914);
      case 'Dark':
        return const Color(0xFF3E2723);
      default:
        return AppTheme.mediumRoast;
    }
  }

  static IconData getIcon(String level) {
    switch (level) {
      case 'Light':
        return Icons.wb_sunny_outlined;
      case 'Medium':
        return Icons.wb_twilight;
      case 'Dark':
        return Icons.nightlight_round;
      default:
        return Icons.coffee;
    }
  }
}

class CoffeeImageView extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CoffeeImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppTheme.cream,
          child: const Icon(Icons.coffee, color: AppTheme.mediumRoast, size: 32),
        ),
      );
    }
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: AppTheme.cream,
        child: const Icon(Icons.coffee, color: AppTheme.mediumRoast, size: 32),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: AppTheme.cream,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.caramel,
              ),
            ),
          ),
        );
      },
    );
  }
}
