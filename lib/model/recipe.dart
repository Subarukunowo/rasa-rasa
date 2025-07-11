class Recipe {
  final int id;
  final int userId;
  final String namaMasakan;
  final int kategoriId;
  final int waktuMemasak;
  final String bahanUtama;
  final String deskripsi;
  final String createdAt;
  final String levelKesulitan;
  final String jenisWaktu;
  final String? video;
  final String gambar;      // nama file gambar (ex: "ayam.jpg")
  final String? gambarUrl;  // URL gambar lengkap (ex: "http://.../ayam.jpg")
  final String userName;

  const Recipe({
    required this.id,
    required this.userId,
    required this.namaMasakan,
    required this.kategoriId,
    required this.waktuMemasak,
    required this.bahanUtama,
    required this.deskripsi,
    required this.createdAt,
    required this.levelKesulitan,
    required this.jenisWaktu,
    
    this.video,
    required this.gambar,
    this.gambarUrl,
    required this.userName,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      namaMasakan: _parseString(json['nama_masakan']),
      kategoriId: _parseInt(json['kategori_id']),
      waktuMemasak: _parseInt(json['waktu_memasak']),
      bahanUtama: _parseString(json['bahan_utama']),
      deskripsi: _parseString(json['deskripsi']),
      createdAt: _parseString(json['created_at']),
      levelKesulitan: _parseString(json['level_kesulitan']),
      jenisWaktu: _parseString(json['jenis_waktu']),
      video: json['video']?.toString(),
      gambar: _parseString(json['gambar']),
      gambarUrl: json['gambar_url']?.toString(),
      userName: _parseString(json['user_name'] ?? json['nama_user'] ?? 'Unknown'),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value) {
    return value?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama_masakan': namaMasakan,
      'kategori_id': kategoriId,
      'waktu_memasak': waktuMemasak,
      'bahan_utama': bahanUtama,
      'deskripsi': deskripsi,
      'created_at': createdAt,
      'level_kesulitan': levelKesulitan,
      'jenis_waktu': jenisWaktu,
      'video': video,
      'gambar': gambar,
      'gambar_url': gambarUrl,
      'user_name': userName,
    };
  }
}
