import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'https://ascend-in.vercel.app/api/v1/auth';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const String _keyToken = 'auth_token';

  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<void> _saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<void> logout() async {
    await _storage.delete(key: _keyToken);
  }

  /// Returns true if a token exists and the server still recognises it.
  /// Silently clears stale / expired tokens.
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 401 || response.statusCode == 403) {
        // Token is expired or invalid — wipe it silently
        await logout();
        return false;
      }
      return response.statusCode == 200;
    } catch (_) {
      // Network error — assume still logged in (token exists) to avoid
      // forcing a re-login every time the user is offline.
      return true;
    }
  }

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Accept 200 or 201 Created
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        await _saveToken(data['token'] as String);
      }
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        await _saveToken(data['token'] as String);
      }
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> linkDevice(String uid) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Not logged in'};

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/link'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'uid': uid}),
          )
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Not logged in'};

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
