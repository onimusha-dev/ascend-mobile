import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:ascend/core/services/app_preferences.dart';

class AnalyticsService {
  /// HACK: this is gonna be replaced with real logic later
  // TODO: Replace with your actual Vercel project URL once deployed
  static const String _baseUrl = 'https://ascend-in.vercel.app/api/v1';

  static const String _keyUserId = 'analytics_user_id';
  static const String _keyErrors = 'analytics_cached_errors';
  static const String _keyHasSentFirstOpen = 'analytics_first_open_sent';

  static String get userId {
    String? uid = AppPreferences.getPreference(_keyUserId);
    if (uid == null) {
      uid = const Uuid().v4();
      AppPreferences.setPreference(_keyUserId, uid);
    }
    return uid;
  }

  // Called each time the app opens (e.g., in main.dart)
  static Future<void> initializeAndPing() async {
    // 1. Send GET on first open or regular open
    final hasSentFirstOpen =
        AppPreferences.getPreferenceBool(_keyHasSentFirstOpen) ?? false;

    try {
      final type = hasSentFirstOpen ? 'app_open' : 'first_open';
      final getUri = Uri.parse('$_baseUrl/ping?uid=$userId&type=$type');

      final response = await http
          .get(getUri)
          .timeout(const Duration(seconds: 10));

      if (!hasSentFirstOpen && response.statusCode == 200) {
        await AppPreferences.setPreferenceBool(_keyHasSentFirstOpen, true);
      }
    } catch (e) {
      debugPrint('Failed to send GET ping: $e');
    }

    // 2. Send POST with any accumulated cached errors from the previous session
    final cachedErrorsStrList =
        AppPreferences.getPreferenceStringList(_keyErrors) ?? [];
    if (cachedErrorsStrList.isNotEmpty) {
      try {
        final postUri = Uri.parse('$_baseUrl/crash');

        final payload = jsonEncode({
          'uid': userId,
          'timestamp': DateTime.now().toIso8601String(),
          'errors': cachedErrorsStrList.map((e) {
            final errorMap = jsonDecode(e);
            return {
              'exception': errorMap['exception'],
              'stackTrace': errorMap['stackTrace'],
            };
          }).toList(),
        });

        final response = await http
            .post(
              postUri,
              headers: {'Content-Type': 'application/json'},
              body: payload,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          // Success, clear the sent errors from local storage
          await AppPreferences.setPreferenceStringList(_keyErrors, []);
        }
      } catch (e) {
        debugPrint('Failed to send cached POST errors: $e');
      }
    }
  }

  // Called when an error gets caught in the Global Error Screen
  static Future<void> logError(String exception, String stackTrace) async {
    final timestamp = DateTime.now().toIso8601String();

    // Attempt instant logging
    try {
      final postUri = Uri.parse('$_baseUrl/crash');
      final payload = jsonEncode({
        'uid': userId,
        'timestamp': timestamp,
        'errors': [
          {'exception': exception, 'stackTrace': stackTrace},
        ],
      });

      final response = await http
          .post(
            postUri,
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Success: no need to cache
        return;
      }
    } catch (e) {
      debugPrint('Failed to log error instantly: $e');
    }

    // Fallback: cache for next app open
    final cachedErrors =
        AppPreferences.getPreferenceStringList(_keyErrors) ?? [];

    final errorEntry = jsonEncode({
      'exception': exception,
      'stackTrace': stackTrace,
      'time': timestamp,
    });

    // Prevent storage bloat: keep max 20 errors
    if (cachedErrors.length > 20) {
      cachedErrors.removeAt(0);
    }

    cachedErrors.add(errorEntry);
    await AppPreferences.setPreferenceStringList(_keyErrors, cachedErrors);
  }
}
