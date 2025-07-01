
// lib/service/api_service.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../model/recipe.dart';
import 'APIService.dart';

// ===== BASE API SERVICE =====
class ResepService extends BaseApiService {
  static const String endpoint = '${BaseApiService.baseUrl}/resep';

  // Read all resep
  static Future<List<Recipe>> fetchResep() async {
    final response = await http.get(Uri.parse('$endpoint/read.php'));
    final data = BaseApiService.handleResponse(response);

    List<Recipe> recipes = [];
    for (var item in data) {
      try {
        debugPrint('✅ ITEM: ${item.runtimeType} | $item');
        if (item is Map<String, dynamic>) {
          final recipe = Recipe.fromJson(item);
          recipes.add(recipe);
        } else {
          debugPrint('❌ Bukan Map<String, dynamic>: ${item.runtimeType}');
        }
      } catch (e) {
        debugPrint('⚠️ Error parsing recipe: $e');
      }
    }
    return recipes;
  }

  // Create resep
  static Future<Map<String, dynamic>> createResep(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$endpoint/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Update resep
  static Future<Map<String, dynamic>> updateResep(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$endpoint/update.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...data, 'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Delete resep
  static Future<Map<String, dynamic>> deleteResep(int id) async {
    final response = await http.delete(
      Uri.parse('$endpoint/delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }
}