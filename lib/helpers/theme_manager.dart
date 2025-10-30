import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  AppThemeData _currentTheme = AppThemeData.themes[0];

  AppThemeData get currentTheme => _currentTheme;

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey);
    
    if (themeName != null) {
      final theme = AppThemeData.themes.firstWhere(
        (t) => t.name == themeName,
        orElse: () => AppThemeData.themes[0],
      );
      _currentTheme = theme;
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeData theme) async {
    _currentTheme = theme;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
  }
}

class AppThemeData {
  final String name;
  final String displayName;
  final List<Color> gradientColors;
  final IconData icon;

  const AppThemeData({
    required this.name,
    required this.displayName,
    required this.gradientColors,
    required this.icon,
  });

  static const List<AppThemeData> themes = [
    AppThemeData(
      name: 'blue_ocean',
      displayName: 'Oceano Azul',
      gradientColors: [
        Color(0xFF1E3C72),
        Color(0xFF2A5298),
        Color(0xFF4A90E2),
        Color(0xFF87CEEB),
      ],
      icon: Icons.water,
    ),
    AppThemeData(
      name: 'purple_dream',
      displayName: 'Sonho Roxo',
      gradientColors: [
        Color(0xFF4A148C),
        Color(0xFF6A1B9A),
        Color(0xFF8E24AA),
        Color(0xFFBA68C8),
      ],
      icon: Icons.auto_awesome,
    ),
    AppThemeData(
      name: 'sunset',
      displayName: 'Pôr do Sol',
      gradientColors: [
        Color(0xFFFF6B6B),
        Color(0xFFFF8E53),
        Color(0xFFFFA07A),
        Color(0xFFFFD93D),
      ],
      icon: Icons.wb_sunny,
    ),
    AppThemeData(
      name: 'forest',
      displayName: 'Floresta',
      gradientColors: [
        Color(0xFF1B5E20),
        Color(0xFF2E7D32),
        Color(0xFF43A047),
        Color(0xFF66BB6A),
      ],
      icon: Icons.forest,
    ),
    AppThemeData(
      name: 'candy',
      displayName: 'Doce',
      gradientColors: [
        Color(0xFFFF6B9D),
        Color(0xFFFFC3A0),
        Color(0xFFFFEAF0),
        Color(0xFFFFF5E4),
      ],
      icon: Icons.cake,
    ),
    AppThemeData(
      name: 'night',
      displayName: 'Noite Estrelada',
      gradientColors: [
        Color(0xFF0F2027),
        Color(0xFF203A43),
        Color(0xFF2C5364),
        Color(0xFF4A6FA5),
      ],
      icon: Icons.nights_stay,
    ),
    AppThemeData(
      name: 'rainbow',
      displayName: 'Arco-íris',
      gradientColors: [
        Color(0xFFFF0080),
        Color(0xFF7928CA),
        Color(0xFF4481EB),
        Color(0xFF04BEFE),
      ],
      icon: Icons.palette,
    ),
  ];
}