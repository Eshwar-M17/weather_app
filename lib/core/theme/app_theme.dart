import 'package:flutter/material.dart';

/// AppTheme provides theme data for the Weather App
///
/// Defines colors, text styles, and other theme elements
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color scheme
  static const Color _primaryColor = Color(0xFF382F70);
  static const Color _darkBlueBackground = Color(0xFF292251);
  static const Color _cardBackgroundColor = Color(0xFF373063);
  static const Color _accentColor = Color(0xFF6A5CFF);
  static const Color _textPrimaryColor = Colors.white;
  static const Color _textSecondaryColor = Color(0xFFB8B5C6);

  // Gradient colors for air quality indicator and other sliders
  static const List<Color> _airQualityGradient = [
    Color(0xFF4286FF),
    Color(0xFF6A5CFF),
    Color(0xFFC45EFF),
    Color(0xFFFF5EBC),
  ];

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: _textTheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: _appBarTheme,
      cardTheme: _lightCardTheme,
      inputDecorationTheme: _inputDecorationTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
    );
  }

  /// Dark theme configuration - main theme for the weather app
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: _textTheme,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: _appBarTheme,
      cardTheme: _darkCardTheme,
      inputDecorationTheme: _inputDecorationTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
    );
  }

  // Text theme
  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        color: _textPrimaryColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: _textPrimaryColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: _textPrimaryColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: _textPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: _textPrimaryColor,
        fontSize: 18,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: _textPrimaryColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: _textSecondaryColor,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        color: _textSecondaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // AppBar theme
  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(
      backgroundColor: _darkBlueBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: _textPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: _textPrimaryColor),
    );
  }

  // Card theme for dark mode
  static CardTheme get _darkCardTheme {
    return const CardTheme(
      color: _cardBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      margin: EdgeInsets.all(8.0),
    );
  }

  // Card theme for light mode
  static CardTheme get _lightCardTheme {
    return CardTheme(
      color: Colors.grey[100],
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      margin: const EdgeInsets.all(8.0),
    );
  }

  // Input decoration theme
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: _cardBackgroundColor,
      hintStyle: const TextStyle(color: _textSecondaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _accentColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Elevated button theme
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        foregroundColor: _textPrimaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  /// Get the gradient for air quality indicators
  static List<Color> get airQualityGradient => _airQualityGradient;

  /// Get the card background color
  static Color get cardBackgroundColor => _cardBackgroundColor;

  /// Get the dark blue background color
  static Color get darkBlueBackground => _darkBlueBackground;

  /// Get the accent color
  static Color get accentColor => _accentColor;
}
