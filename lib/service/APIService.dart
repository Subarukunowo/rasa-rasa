
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
  final statusCode = response.statusCode;

  if (statusCode == 200 || statusCode == 201) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Response tidak dapat diparsing');
    }
  } else {
    throw Exception('Failed to load data : $statusCode');
  }
}
}