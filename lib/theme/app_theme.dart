import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // WhatsApp exact brand colors
  static const Color whatsappGreen = Color(0xFF075E54);
  static const Color whatsappTeal = Color(0xFF128C7E);
  static const Color whatsappLightGreen = Color(0xFF25D366);
  static const Color whatsappBlueTick = Color(0xFF53BDEB);

  // Light Theme
  static const Color _lightPrimary = Color(0xFF008069);
  static const Color _lightAppBar = Color(0xFF008069);
  static const Color _lightScaffold = Color(0xFFFFFFFF);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF111B21);
  static const Color _lightTextSecondary = Color(0xFF667781);
  static const Color _lightDivider = Color(0xFFE9EDEF);

  // Dark Theme
  static const Color _darkPrimary = Color(0xFF00A884);
  static const Color _darkAppBar = Color(0xFF1F2C34);
  static const Color _darkScaffold = Color(0xFF111B21);
  static const Color _darkSurface = Color(0xFF111B21);
  static const Color _darkTextPrimary = Color(0xFFE9EDEF);
  static const Color _darkTextSecondary = Color(0xFF8696A0);
  static const Color _darkDivider = Color(0xFF222D34);

  // Chat colors
  static const Color lightChatBg = Color(0xFFEFE7DE);
  static const Color darkChatBg = Color(0xFF0B141A);

  static const Color lightMyBubble = Color(0xFFD9FDD3);
  static const Color lightOtherBubble = Color(0xFFFFFFFF);

  static const Color darkMyBubble = Color(0xFF005C4B);
  static const Color darkOtherBubble = Color(0xFF202C33);

  static const Color readTick = Color(0xFF53BDEB);

  // Input field colors
  static const Color lightInputBg = Color(0xFFFFFFFF);
  static const Color darkInputBg = Color(0xFF2A3942);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      onSurfaceVariant: _lightTextSecondary,
      outline: _lightDivider,
      secondary: _lightPrimary,
    ),
    scaffoldBackgroundColor: _lightScaffold,
    dividerColor: _lightDivider,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightAppBar,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00A884),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _lightDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _lightDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _lightPrimary),
      ),
      labelStyle: const TextStyle(color: _lightTextSecondary),
      hintStyle: const TextStyle(color: _lightTextSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimary,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return _lightPrimary;
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _lightPrimary.withValues(alpha: 0.5);
        }
        return const Color(0xFFB0BEC5);
      }),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _lightSurface,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF323232),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: _lightTextPrimary),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: _lightTextPrimary),
      titleMedium: TextStyle(fontWeight: FontWeight.w500, color: _lightTextPrimary),
      bodyLarge: TextStyle(color: _lightTextPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: _lightTextSecondary, fontSize: 14),
      bodySmall: TextStyle(color: _lightTextSecondary, fontSize: 12),
      labelSmall: TextStyle(color: _lightTextSecondary, fontSize: 11),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      onSurfaceVariant: _darkTextSecondary,
      outline: _darkDivider,
      secondary: _darkPrimary,
    ),
    scaffoldBackgroundColor: _darkScaffold,
    dividerColor: _darkDivider,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkAppBar,
      foregroundColor: _darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _darkTextPrimary,
        letterSpacing: 0,
      ),
      iconTheme: IconThemeData(color: _darkTextSecondary),
    ),
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00A884),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A3942),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _darkDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _darkDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _darkPrimary),
      ),
      labelStyle: const TextStyle(color: _darkTextSecondary),
      hintStyle: const TextStyle(color: _darkTextSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimary,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return _darkPrimary;
        return const Color(0xFF8696A0);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkPrimary.withValues(alpha: 0.5);
        }
        return const Color(0xFF3B4A54);
      }),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: const Color(0xFF233138),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF233138),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF323232),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: _darkTextPrimary),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: _darkTextPrimary),
      titleMedium: TextStyle(fontWeight: FontWeight.w500, color: _darkTextPrimary),
      bodyLarge: TextStyle(color: _darkTextPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: _darkTextSecondary, fontSize: 14),
      bodySmall: TextStyle(color: _darkTextSecondary, fontSize: 12),
      labelSmall: TextStyle(color: _darkTextSecondary, fontSize: 11),
    ),
  );

  static Color getChatBackground(bool isDark) => isDark ? darkChatBg : lightChatBg;
  static Color getMyMessageBubble(bool isDark) => isDark ? darkMyBubble : lightMyBubble;
  static Color getOtherMessageBubble(bool isDark) => isDark ? darkOtherBubble : lightOtherBubble;
  static Color getInputBackground(bool isDark) => isDark ? darkInputBg : lightInputBg;
}
