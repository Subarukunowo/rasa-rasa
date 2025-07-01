// ===== BAHAN MASAKAN SERVICE =====
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'APIService.dart';

class BahanMasakanService extends BaseApiService {
  static const String endpoint = '${BaseApiService.baseUrl}/bahan_masakan';

  // Read all bahan masakan
  static Future<List<dynamic>> fetchBahanMasakan() async {
    final response = await http.get(Uri.parse('$endpoint/read.php'));
    return BaseApiService.handleResponse(response);
  }

  // Create bahan masakan
  static Future<Map<String, dynamic>> createBahanMasakan(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$endpoint/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Update bahan masakan
  static Future<Map<String, dynamic>> updateBahanMasakan(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$endpoint/update.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...data, 'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Delete bahan masakan
  static Future<Map<String, dynamic>> deleteBahanMasakan(int id) async {
    final response = await http.delete(
      Uri.parse('$endpoint/delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }
}