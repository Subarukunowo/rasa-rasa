// lib/model/langkah_resep.dart

class LangkahResep {
  final int id;
  final int resepId;
  final int urutan;
  final String judul;
  final String deskripsi;

  LangkahResep({
    required this.id,
    required this.resepId,
    required this.urutan,
    required this.judul,
    required this.deskripsi,
  });

  factory LangkahResep.fromJson(Map<String, dynamic> json) {
    return LangkahResep(
      id: int.parse(json['id'].toString()),
      resepId: int.parse(json['resep_id'].toString()),
      urutan: int.parse(json['urutan'].toString()),
      judul: json['judul'],
      deskripsi: json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resep_id': resepId,
      'urutan': urutan,
      'judul': judul,
      'deskripsi': deskripsi,
    };
  }
}

// Digunakan saat membuat langkah baru
class CreateLangkahResepRequest {
  final int resepId;
  final int urutan;
  final String judul;
  final String deskripsi;

  CreateLangkahResepRequest({
    required this.resepId,
    required this.urutan,
    required this.judul,
    required this.deskripsi,
  });

  Map<String, dynamic> toJson() {
    return {
      'resep_id': resepId,
      'urutan': urutan,
      'judul': judul,
      'deskripsi': deskripsi,
    };
  }
}

// Digunakan saat mengupdate langkah
class UpdateLangkahResepRequest {
  final int id;
  final int resepId;
  final int urutan;
  final String judul;
  final String deskripsi;

  UpdateLangkahResepRequest({
    required this.id,
    required this.resepId,
    required this.urutan,
    required this.judul,
    required this.deskripsi,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resep_id': resepId,
      'urutan': urutan,
      'judul': judul,
      'deskripsi': deskripsi,
    };
  }
}

// Digunakan untuk reorder
class ReorderLangkahResepRequest {
  final List<int> langkahIds;

  ReorderLangkahResepRequest({required this.langkahIds});

  Map<String, dynamic> toJson() {
    return {
      'langkah_ids': langkahIds,
    };
  }
}
