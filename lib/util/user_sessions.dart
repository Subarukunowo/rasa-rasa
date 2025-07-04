class UserSession {
  static UserSession? _instance;
  static UserSession get instance => _instance ??= UserSession._();
  UserSession._();

  Map<String, dynamic>? _currentUser;
  String? _token;

  void setUser(Map<String, dynamic> userData, String token) {
    _currentUser = userData;
    _token = token;
  }

  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null && _token != null;

  void clearSession() {
    _currentUser = null;
    _token = null;
  }
}
