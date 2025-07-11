class ProfileSession {
  static ProfileSession? _instance;
  static ProfileSession get instance => _instance ??= ProfileSession._();
  ProfileSession._();

  Map<String, dynamic>? _profileData;

  void setProfile(Map<String, dynamic> profile) {
    _profileData = profile;
  }

  Map<String, dynamic>? get profile => _profileData;
  int? get id => _profileData?['id'];
  int? get userId => _profileData?['user_id'];
  String? get namaLengkap => _profileData?['nama_lengkap'];
  String? get bio => _profileData?['bio'];
  String? get foto => _profileData?['foto'];

  void clear() {
    _profileData = null;
  }
}
