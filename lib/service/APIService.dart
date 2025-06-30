// lib/service/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.1.5/rasa-rasa/api';

  // ===== USER =====
  static Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/user/index.php'));
    return _handleResponse(response);
  }

  // ===== PROFIL =====
  static Future<List<dynamic>> fetchProfiles() async {
    final response = await http.get(Uri.parse('$_baseUrl/profil/index.php'));
    return _handleResponse(response);
  }

  // ===== RESEP =====
  static Future<List<dynamic>> fetchResep() async {
    final response = await http.get(Uri.parse('$_baseUrl/resep/read.php'));
    return _handleResponse(response);
  }

  // ===== BAHAN MASAKAN =====
  static Future<List<dynamic>> fetchBahanMasakan() async {
    final response = await http.get(Uri.parse('$_baseUrl/bahan_masakan/index.php'));
    return _handleResponse(response);
  }

  // ===== KATEGORI =====
  static Future<List<dynamic>> fetchKategori() async {
    final response = await http.get(Uri.parse('$_baseUrl/kategori/index.php'));
    return _handleResponse(response);
  }

  // ===== NOTIFIKASI =====
  static Future<List<dynamic>> fetchNotifikasi() async {
    final response = await http.get(Uri.parse('$_baseUrl/notifikasi/index.php'));
    return _handleResponse(response);
  }

  // ===== KOMENTAR =====
  static Future<List<dynamic>> fetchKomentar() async {
    final response = await http.get(Uri.parse('$_baseUrl/komentar/index.php'));
    return _handleResponse(response);
  }

  // ===== Helper =====
  static List<dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
