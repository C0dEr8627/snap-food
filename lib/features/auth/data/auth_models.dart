class AuthUser {
  const AuthUser(this.payload);
  final Map<String, dynamic> payload;
  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      AuthUser(Map<String, dynamic>.unmodifiable(json));
}

class AuthSession {
  const AuthSession({required this.token, required this.user});
  final String token;
  final AuthUser user;
}
