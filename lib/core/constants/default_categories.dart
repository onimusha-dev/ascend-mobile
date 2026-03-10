import 'package:flutter/material.dart';

class DefaultCategory {
  final String name;
  final String icon;

  const DefaultCategory({required this.name, required this.icon});
}

final List<DefaultCategory> defaultCategories = [
  DefaultCategory(name: 'Work', icon: Icons.work_rounded.codePoint.toString()),
  DefaultCategory(
    name: 'Education',
    icon: Icons.school_rounded.codePoint.toString(),
  ),
  DefaultCategory(
    name: 'Personal',
    icon: Icons.home_rounded.codePoint.toString(),
  ),
  DefaultCategory(
    name: 'Health',
    icon: Icons.fitness_center_rounded.codePoint.toString(),
  ),
  DefaultCategory(
    name: 'Travel',
    icon: Icons.flight_rounded.codePoint.toString(),
  ),
];
