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

  // Read resep by ID
  static Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      debugPrint('🔍 Fetching recipe detail for ID: $recipeId');

      final response = await http.get(
        Uri.parse('$endpoint/read.php?id=$recipeId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true && decoded['data'] != null) {
          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            return Recipe.fromJson(data);
          } else if (data is List && data.isNotEmpty) {
            return Recipe.fromJson(data.first);
          }
        } else if (decoded['data'] != null) {
          final data = decoded['data'];
          if (data is List && data.isNotEmpty) {
            for (var item in data) {
              if (item['id'].toString() == recipeId) {
                return Recipe.fromJson(item);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching recipe by ID: $e');
    }

    return null;
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
  // Get resep by user_id
static Future<List<Recipe>> getResepByUserId(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('$endpoint/read_user.php?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded['success'] == true && decoded['data'] != null) {
        List data = decoded['data'];
        return data.map((item) => Recipe.fromJson(item)).toList();
      }
    } else {
      debugPrint('❌ Failed to load user recipes: ${response.body}');
    }
  } catch (e) {
    debugPrint('❌ Error fetching user recipes: $e');
  }

  return [];
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
  static Future<bool> toggleFavorite(String recipeId) async {
    try {
      final response = await http.post(
        Uri.parse('$endpoint/favorite/toggle.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'recipe_id': recipeId}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }
}
