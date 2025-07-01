import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/langkah_resep.dart';

class LangkahResepService {
  static const String baseUrl = 'http://192.168.1.5/rasa-rasa/api';
  static const String endpoint = '$baseUrl/langkah_resep';

  // ===== READ =====

  /// Get langkah resep berdasarkan resep ID
  static Future<List<LangkahResep>> getLangkahResepByResepId(int resepId) async {
    try {
      debugPrint('🔍 Fetching langkah resep for resep ID: $resepId');
      final response = await http.get(
        Uri.parse('$endpoint/read.php?resep_id=$resepId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return List<LangkahResep>.from(
            decoded['data'].map((json) => LangkahResep.fromJson(json)),
          );
        }
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching langkah resep: $e');
      throw Exception('Failed to fetch langkah resep: $e');
    }
  }

  /// Get semua langkah resep
  static Future<List<LangkahResep>> getAllLangkahResep() async {
    try {
      final response = await http.get(
        Uri.parse('$endpoint/read.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return List<LangkahResep>.from(
            decoded['data'].map((json) => LangkahResep.fromJson(json)),
          );
        }
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching all langkah resep: $e');
      throw Exception('Failed to fetch all langkah resep: $e');
    }
  }

  /// Get langkah resep berdasarkan ID
  static Future<LangkahResep?> getLangkahResepById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$endpoint/read.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return LangkahResep.fromJson(decoded['data']);
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching langkah resep by ID: $e');
      return null;
    }
  }

  // ===== CREATE =====

  /// Tambah langkah resep
  static Future<LangkahResep?> createLangkahResep(CreateLangkahResepRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$endpoint/create.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      debugPrint('📡 Create response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return LangkahResep.fromJson(decoded['data']);
        }
      }

      throw Exception('Failed to create langkah resep');
    } catch (e) {
      debugPrint('❌ Error creating langkah resep: $e');
      throw Exception('Failed to create langkah resep: $e');
    }
  }

  // ===== UPDATE =====

  /// Update langkah resep
  static Future<bool> updateLangkahResep(UpdateLangkahResepRequest request) async {
    try {
      final response = await http.put(
        Uri.parse('$endpoint/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      debugPrint('📡 Update response: ${response.statusCode} - ${response.body}');

      return response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true;
    } catch (e) {
      debugPrint('❌ Error updating langkah resep: $e');
      return false;
    }
  }

  /// Reorder langkah resep berdasarkan ID
  static Future<bool> reorderLangkahResep(List<int> langkahIds) async {
    try {
      final response = await http.put(
        Uri.parse('$endpoint/reorder.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'langkah_ids': langkahIds}),
      );

      debugPrint('📡 Reorder response: ${response.statusCode} - ${response.body}');

      return response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true;
    } catch (e) {
      debugPrint('❌ Error reordering langkah resep: $e');
      return false;
    }
  }

  // ===== DELETE =====

  /// Hapus langkah resep berdasarkan ID
  static Future<bool> deleteLangkahResep(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$endpoint/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      debugPrint('📡 Delete response: ${response.statusCode} - ${response.body}');

      return response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true;
    } catch (e) {
      debugPrint('❌ Error deleting langkah resep: $e');
      return false;
    }
  }

  // ===== HELPER =====

  /// Tambah banyak langkah resep sekaligus
  static Future<List<LangkahResep>> createMultipleLangkahResep(
      int resepId, List<Map<String, String>> langkahList) async {
    List<LangkahResep> result = [];

    try {
      for (int i = 0; i < langkahList.length; i++) {
        final request = CreateLangkahResepRequest(
          resepId: resepId,
          urutan: i + 1,
          judul: langkahList[i]['judul'] ?? '',
          deskripsi: langkahList[i]['deskripsi'] ?? '',
        );

        final created = await createLangkahResep(request);
        if (created != null) result.add(created);
      }
    } catch (e) {
      debugPrint('❌ Error creating multiple langkah resep: $e');
    }

    return result;
  }

  /// Perbarui urutan langkah resep berdasarkan daftar objek
  static Future<bool> updateLangkahOrder(List<LangkahResep> langkahList) async {
    try {
      langkahList.sort((a, b) => a.urutan.compareTo(b.urutan));
      final ids = langkahList.map((e) => e.id).toList();
      return await reorderLangkahResep(ids);
    } catch (e) {
      debugPrint('❌ Error updating langkah order: $e');
      return false;
    }
  }

  /// Format langkah-langkah menjadi string untuk ditampilkan
  static String formatLangkahForDisplay(List<LangkahResep> langkahList) {
    if (langkahList.isEmpty) return 'Belum ada langkah-langkah.';

    return langkahList.map((e) => '${e.urutan}. ${e.judul}\n   ${e.deskripsi}\n').join('\n').trim();
  }

  /// Validasi data langkah resep
  static String? validateLangkahResep({
    required String judul,
    required String deskripsi,
  }) {
    if (judul.trim().isEmpty) return 'Judul langkah tidak boleh kosong';
    if (judul.trim().length < 3) return 'Judul langkah minimal 3 karakter';
    if (deskripsi.trim().isEmpty) return 'Deskripsi langkah tidak boleh kosong';
    if (deskripsi.trim().length < 10) return 'Deskripsi langkah minimal 10 karakter';
    return null;
  }
}
