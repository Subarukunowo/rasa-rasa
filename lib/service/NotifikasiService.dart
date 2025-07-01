// ===== NOTIFIKASI SERVICE =====
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'APIService.dart';

class NotifikasiService extends BaseApiService {
  static const String endpoint = '${BaseApiService.baseUrl}/notifikasi';

  // Read all notifikasi
  static Future<List<dynamic>> fetchNotifikasi() async {
    final response = await http.get(Uri.parse('$endpoint/read.php'));
    return BaseApiService.handleResponse(response);
  }

  // Create notifikasi
  static Future<Map<String, dynamic>> createNotifikasi(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$endpoint/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Update notifikasi
  static Future<Map<String, dynamic>> updateNotifikasi(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$endpoint/update.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...data, 'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Delete notifikasi
  static Future<Map<String, dynamic>> deleteNotifikasi(int id) async {
    final response = await http.delete(
      Uri.parse('$endpoint/delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }
}