import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthSessionService {
  static final AuthSessionService _instance = AuthSessionService._internal();
  factory AuthSessionService() => _instance;
  AuthSessionService._internal();

  static const String _keyToken = 'saici_token';
  static const String _keyUser = 'saici_user';

  String? _cachedToken;
  UserModel? _cachedUser;

  String? get token => _cachedToken;
  UserModel? get currentUser => _cachedUser;

  bool get isAuthenticated => _cachedToken != null && _cachedToken!.isNotEmpty;

  String get currentRole => (_cachedUser?.rol ?? '').toUpperCase();
  String get currentTipo => (_cachedUser?.tipo ?? '').toUpperCase();

  bool hasRole(List<String> allowedRoles) {
    if (!isAuthenticated) return false;
    final normalized = allowedRoles.map((r) => r.toUpperCase()).toList();
    return normalized.contains(currentRole) || normalized.contains(currentTipo);
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_keyToken);
    final userJson = prefs.getString(_keyUser);
    if (userJson != null) {
      try {
        _cachedUser = UserModel.fromJson(jsonDecode(userJson));
      } catch (_) {
        _cachedUser = null;
      }
    }
  }

  Future<void> saveSession(String token, UserModel user) async {
    _cachedToken = token;
    _cachedUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<void> updateCurrentUser(UserModel user) async {
    _cachedUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    _cachedToken = null;
    _cachedUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }
}
