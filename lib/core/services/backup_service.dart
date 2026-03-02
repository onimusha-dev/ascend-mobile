import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ascend/core/services/auth_service.dart';

class BackupService {
  static const String _baseUrl = 'https://ascend-in.vercel.app/api/v1/backup';

  /// Uploads a backup file (SQLite or JSON) to the cloud.
  static Future<Map<String, dynamic>> uploadBackup(File backupFile) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not logged in'};

    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload'))
            ..headers['Authorization'] = 'Bearer $token'
            ..files.add(
              await http.MultipartFile.fromPath('backup', backupFile.path),
            );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Lists all cloud backups for the currently logged in user.
  static Future<Map<String, dynamic>> listBackups() async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not logged in'};

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/list'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
