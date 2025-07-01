// ===== KOMENTAR SERVICE =====
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'APIService.dart';

class KomentarService extends BaseApiService {
  static const String endpoint = '${BaseApiService.baseUrl}/komentar';

  // Read all komentar
  static Future<List<dynamic>> fetchKomentar() async {
    final response = await http.get(Uri.parse('$endpoint/read.php'));
    return BaseApiService.handleResponse(response);
  }

  // Create komentar
  static Future<Map<String, dynamic>> createKomentar(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$endpoint/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Update komentar
  static Future<Map<String, dynamic>> updateKomentar(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$endpoint/update.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...data, 'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Delete komentar
  static Future<Map<String, dynamic>> deleteKomentar(int id) async {
    final response = await http.delete(
      Uri.parse('$endpoint/delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }
}