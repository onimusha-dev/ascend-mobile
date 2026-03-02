import 'package:flutter/material.dart';

class MotivationConstants {
  static const List<String> quotes = [
    "Small steps lead to big results.",
    "Focus on being productive instead of busy.",
    "The secret of getting ahead is getting started.",
    "It’s not about having time. It’s about making time.",
    "Don't count the days, make the days count.",
    "Productivity is never an accident.",
    "Starve your distractions, feed your focus.",
    "Your future is created by what you do today.",
  ];
}

class AppConstants {
  static const String appName = 'Ascend';
  static const String appVersion = '1.0.0';
  static const String versionName = 'Ascend v1.0.0';

  // URLs
  static const String discordUrl = 'https://discord.gg/SqDNVhhdHV';
  static const String githubUrl =
      'https://github.com/onimusha-dev/simple-task-manager-app';
  static const String telegramUrl = 'https://t.me/+3sRfr-qGQ4BkZDRl';
  static const String websiteUrl = 'https://onimusha-dev.github.io/Ascend';
  static const String email = 'musaddik.dev@gmail.com';
  static const String author = '鬼 musha';
}

class DatabaseConstants {
  static const String name = 'journal_app_db';

  // Drift appends '.sqlite' to the database name by default
  static const String fileName = '$name.sqlite';
  static const String walFileName = '$fileName-wal';
  static const String shmFileName = '$fileName-shm';
}

class CategoryIcons {
  // Predefined default categories with Material Icons
  static const List<Map<String, String>> predefinedCategories = [
    {'name': 'Work', 'icon': '58905'}, // Icons.work_rounded
    {'name': 'Study', 'icon': '62111'}, // Icons.school_rounded
    {'name': 'Home', 'icon': '58172'}, // Icons.home_rounded
    {'name': 'Gym', 'icon': '57849'}, // Icons.fitness_center_rounded
    {'name': 'Travel', 'icon': '57887'}, // Icons.flight_rounded
    {'name': 'Shopping', 'icon': '58778'}, // Icons.shopping_cart_rounded
    {'name': 'Personal', 'icon': '57962'}, // Icons.favorite_rounded
    {'name': 'Ideas', 'icon': '58356'}, // Icons.lightbulb_rounded
    {'name': 'Urgent', 'icon': '58394'}, // Icons.local_fire_department_rounded
    {'name': 'Reading', 'icon': '58451'}, // Icons.menu_book_rounded
    {'name': 'Gaming', 'icon': '58872'}, // Icons.sports_esports_rounded
    {'name': 'Food', 'icon': '58014'}, // Icons.fastfood_rounded
    {'name': 'Hobby', 'icon': '58572'}, // Icons.palette_rounded
    {'name': 'Finance', 'icon': '57530'}, // Icons.attach_money_rounded
    {'name': 'Special', 'icon': '60133'}, // Icons.rocket_launch_rounded
    {'name': 'Car', 'icon': '57913'}, // Icons.directions_car_rounded
    {'name': 'Music', 'icon': '58483'}, // Icons.music_note_rounded
    {'name': 'Pets', 'icon': '58596'}, // Icons.pets_rounded
    {'name': 'Park', 'icon': '58580'}, // Icons.park_rounded
  ];

  // Predefined set of Material Icon code points for the custom picker
  static const List<String> premiumIcons = [
    '58905', // Icons.work_rounded
    '62111', // Icons.school_rounded
    '58172', // Icons.home_rounded
    '57849', // Icons.fitness_center_rounded
    '57887', // Icons.flight_rounded
    '58778', // Icons.shopping_cart_rounded
    '57962', // Icons.favorite_rounded
    '58356', // Icons.lightbulb_rounded
    '58394', // Icons.local_fire_department_rounded
    '58451', // Icons.menu_book_rounded
    '58872', // Icons.sports_esports_rounded
    '58014', // Icons.fastfood_rounded
    '58572', // Icons.palette_rounded
    '57530', // Icons.attach_money_rounded
    '60133', // Icons.rocket_launch_rounded
    '57913', // Icons.directions_car_rounded
    '58483', // Icons.music_note_rounded
    '58596', // Icons.pets_rounded
    '58580', // Icons.park_rounded
    '59021', // Icons.star_rounded
    '59114', // Icons.verified_rounded
    '57896', // Icons.done_all_rounded
    '58321', // Icons.label_important_rounded
    '58000', // Icons.explore_rounded
  ];

  static const Map<String, IconData> iconMap = {
    '58905': Icons.work_rounded,
    '62111': Icons.school_rounded,
    '58172': Icons.home_rounded,
    '57849': Icons.fitness_center_rounded,
    '57887': Icons.flight_rounded,
    '58778': Icons.shopping_cart_rounded,
    '57962': Icons.favorite_rounded,
    '58356': Icons.lightbulb_rounded,
    '58394': Icons.local_fire_department_rounded,
    '58451': Icons.menu_book_rounded,
    '58872': Icons.sports_esports_rounded,
    '58014': Icons.fastfood_rounded,
    '58572': Icons.palette_rounded,
    '57530': Icons.attach_money_rounded,
    '60133': Icons.rocket_launch_rounded,
    '57913': Icons.directions_car_rounded,
    '58483': Icons.music_note_rounded,
    '58596': Icons.pets_rounded,
    '58580': Icons.park_rounded,
    '59021': Icons.star_rounded,
    '59114': Icons.verified_rounded,
    '57896': Icons.done_all_rounded,
    '58321': Icons.label_important_rounded,
    '58000': Icons.explore_rounded,
  };
}
