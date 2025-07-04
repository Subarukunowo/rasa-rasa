
// lib/service/api_service.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:rasarasa_app/model/recipe.dart';

// ===== BASE API SERVICE =====
class BaseApiService {
  static const String baseUrl = 'http://192.168.0.104/rasa-rasa/api';

  static List<dynamic> handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? []; // Ambil hanya bagian data dari JSON
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

 static Map<String, dynamic> handleSingleResponse(http.Response response) {
  print('📦 Status code: ${response.statusCode}');
  print('📥 Response body: ${response.body}');

  if (response.statusCode == 200) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        print('⚠️ Response bukan Map: $decoded');
        return {};
      }
    } catch (e) {
      print('❌ JSON decode error: $e');
      return {};
    }
  } else {
    throw Exception('Failed to load data: ${response.statusCode}');
  }
}
}