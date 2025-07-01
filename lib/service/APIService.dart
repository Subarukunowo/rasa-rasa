
// lib/service/api_service.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:rasarasa_app/model/recipe.dart';

// ===== BASE API SERVICE =====
class BaseApiService {
  static const String baseUrl = 'http://192.168.1.5/rasa-rasa/api';

  static List<dynamic> handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? []; // Ambil hanya bagian data dari JSON
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  static Map<String, dynamic> handleSingleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? {}; // Untuk response single object
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}