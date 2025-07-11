import 'dart:convert';
import 'package:http/http.dart' as http;
import 'APIService.dart';
import '../model/langkah_resep.dart';

class LangkahResepService {
  static const String endpoint = '${BaseApiService.baseUrl}/langkah_resep';

  /// Get by resep ID
  static Future<List<LangkahResep>> getLangkahResepByResepId(int resepId) async {
    final response = await http.get(Uri.parse('$endpoint/read.php?resep_id=$resepId'));
    final data = BaseApiService.handleResponse(response);
    return data.map<LangkahResep>((json) => LangkahResep.fromJson(json)).toList();
  }

  /// Get all
  static Future<List<LangkahResep>> getAllLangkahResep() async {
    final response = await http.get(Uri.parse('$endpoint/read.php'));
    final data = BaseApiService.handleResponse(response);
    return data.map<LangkahResep>((json) => LangkahResep.fromJson(json)).toList();
  }

  /// Get by ID
  static Future<LangkahResep?> getLangkahResepById(int id) async {
    final response = await http.get(Uri.parse('$endpoint/read.php?id=$id'));
    final decoded = BaseApiService.handleSingleResponse(response);

    if (decoded['success'] == true && decoded['data'] != null) {
      return LangkahResep.fromJson(decoded['data']);
    }
    return null;
  }

  /// Create
  static Future<LangkahResep?> createLangkahResep(CreateLangkahResepRequest request) async {
    final response = await http.post(
      Uri.parse('$endpoint/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    final decoded = BaseApiService.handleSingleResponse(response);
    if (decoded['success'] == true && decoded['data'] != null) {
      return LangkahResep.fromJson(decoded['data']);
    }
    return null;
  }

  /// Update
  static Future<bool> updateLangkahResep(UpdateLangkahResepRequest request) async {
    final response = await http.put(
      Uri.parse('$endpoint/update.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    final decoded = BaseApiService.handleSingleResponse(response);
    return decoded['success'] == true;
  }
static Future<void> updateMultipleLangkahResep(int resepId, List<LangkahResep> langkahList) async {
  for (var langkah in langkahList) {
    final request = UpdateLangkahResepRequest(
      id: langkah.id,
      resepId: resepId,
    urutan: langkah.urutan,
  judul: langkah.judul.trim(),
  deskripsi: langkah.deskripsi.trim(),
    );
    await updateLangkahResep(request);
  }
}

  /// Reorder
  static Future<bool> reorderLangkahResep(List<int> langkahIds) async {
    final response = await http.put(
      Uri.parse('$endpoint/reorder.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'langkah_ids': langkahIds}),
    );
    final decoded = BaseApiService.handleSingleResponse(response);
    return decoded['success'] == true;
  }

  /// Delete
  static Future<bool> deleteLangkahResep(int id) async {
    final response = await http.delete(
      Uri.parse('$endpoint/delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    final decoded = BaseApiService.handleSingleResponse(response);
    return decoded['success'] == true;
  }

  // ===== Helpers =====

  static Future<List<LangkahResep>> createMultipleLangkahResep(int resepId, List<Map<String, String>> langkahList) async {
    List<LangkahResep> result = [];
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
    return result;
  }

  static Future<bool> updateLangkahOrder(List<LangkahResep> langkahList) async {
    langkahList.sort((a, b) => a.urutan.compareTo(b.urutan));
    final ids = langkahList.map((e) => e.id).toList();
    return await reorderLangkahResep(ids);
  }

  static String formatLangkahForDisplay(List<LangkahResep> list) {
    if (list.isEmpty) return 'Belum ada langkah-langkah.';
    return list.map((e) => '${e.urutan}. ${e.judul}\n   ${e.deskripsi}\n').join('\n').trim();
  }

  static String? validateLangkahResep({
    required String judul,
    required String deskripsi,
  }) {
    if (judul.trim().isEmpty) return 'Judul tidak boleh kosong';
    if (judul.trim().length < 3) return 'Judul minimal 3 karakter';
    if (deskripsi.trim().isEmpty) return 'Deskripsi tidak boleh kosong';
    if (deskripsi.trim().length < 10) return 'Deskripsi minimal 10 karakter';
    return null;
  }
}
