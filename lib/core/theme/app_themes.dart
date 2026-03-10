import 'package:flutter/material.dart';

class AppThemePreset {
  final String name;
  final Color seedColor;
  final bool useDynamic;

  const AppThemePreset({
    required this.name,
    required this.seedColor,
    this.useDynamic = false,
  });
}

class AppThemes {
  static const violet = AppThemePreset(
    name: 'Violet',
    seedColor: Colors.deepPurple,
  );

  static const dynamic = AppThemePreset(
    name: 'Dynamic',
    seedColor: Colors.blue, // fallback only
    useDynamic: true,
  );

  static const miku = AppThemePreset(
    name: 'Miku',
    seedColor: Color(0xFF00BFA6),
  );

  static const presets = [miku, dynamic, violet];
}
