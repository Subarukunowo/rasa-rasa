import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiService.dart';

class ProfilService extends BaseApiService {
  static const String _updateEndpoint = '${BaseApiService.baseUrl}/user/profil.php';
  static const String _readEndpoint = '${BaseApiService.baseUrl}/user/read_profil.php';

  /// 🔄 Update profil (POST ke profil.php)
  static Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> data) async {
    final uri = Uri.parse(_updateEndpoint);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    return BaseApiService.handleSingleResponse(response);
  }

  /// 📥 Ambil profil berdasarkan user_id (GET ke read_profil.php)
  static Future<Map<String, dynamic>?> fetchProfileByUserId(int userId) async {
    final uri = Uri.parse('$_readEndpoint?user_id=$userId');

    final response = await http.get(uri);

    return BaseApiService.handleSingleResponse(response);
  }
}