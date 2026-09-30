part of '../main.dart';

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final String role;

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: (json['id'] as num).toInt(),
    name: (json['name'] as String?) ?? 'Admin',
    email: (json['email'] as String?) ?? '',
    role: (json['role'] as String?) ?? '',
  );
}

class AdminAuthService {
  static const _tokenKey = 'snap_foodd_admin_token';

  String get _baseUrl {
    final configured = apiBaseUrl.trim();
    return configured.isEmpty ? 'http://localhost:8000/api/v1' : configured.replaceAll(RegExp(r'/$'), '');
  }

  String? get token => html.window.localStorage[_tokenKey];

  Future<AdminUser?> restoreSession() async {
    final currentToken = token;
    if (currentToken == null || currentToken.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: _headers(currentToken),
      );

      if (response.statusCode != 200) {
        await clearSession();
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final user = AdminUser.fromJson(
        (body['data'] as Map<String, dynamic>)['user'] as Map<String, dynamic>,
      );

      if (user.role != 'ADMIN') {
        await clearSession();
        return null;
      }

      return user;
    } catch (_) {
      return null;
    }
  }

  Future<AdminUser> loginWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/admin/password'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    return _handleLoginResponse(response);
  }

  Future<AdminUser> loginWithGoogle(String credential) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/admin/google'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'credential': credential}),
    );

    return _handleLoginResponse(response);
  }

  Future<void> logout() async {
    final currentToken = token;
    try {
      if (currentToken != null && currentToken.isNotEmpty) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: _headers(currentToken),
        );
      }
    } finally {
      await clearSession();
    }
  }

  Future<void> clearSession() async {
    html.window.localStorage.remove(_tokenKey);
  }

  Future<AdminUser> _handleLoginResponse(http.Response response) async {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = body?['code'] as String?;
      final message = switch (code) {
        'ADMIN_ACCESS_REQUIRED' => 'This Google account is not authorized for the admin dashboard.',
        'ACCOUNT_INACTIVE' => 'This admin account is inactive.',
        'INVALID_GOOGLE_CREDENTIAL' => 'Google sign-in could not be verified.',
        'INVALID_CREDENTIALS' => 'The email or password is incorrect.',
        _ => body?['message'] as String? ?? 'Sign-in failed. Please try again.',
      };
      throw AdminAuthException(message);
    }

    final data = body?['data'] as Map<String, dynamic>?;
    final tokenValue = data?['token'] as String?;
    final userJson = data?['user'] as Map<String, dynamic>?;

    if (tokenValue == null || userJson == null) {
      throw const AdminAuthException('The server returned an invalid sign-in response.');
    }

    final user = AdminUser.fromJson(userJson);
    if (user.role != 'ADMIN') {
      throw const AdminAuthException('This account is not authorized for the admin dashboard.');
    }

    html.window.localStorage[_tokenKey] = tokenValue;
    return user;
  }

  Map<String, String> _headers(String currentToken) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $currentToken',
  };
}

class AdminAuthException implements Exception {
  const AdminAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
