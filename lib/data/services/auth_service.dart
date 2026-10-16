import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_helper.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;
  bool get isAuthenticated => _currentUser.value != null;

  static const String _sessionKey = 'logged_in_user_id';
  static const String _salt = 'Mad_Lab2_Salt_2026_Secure';

  /// Hash password using SHA-256 with a security salt to ensure no plain-text storage
  String hashPassword(String password) {
    final bytes = utf8.encode(password + _salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Initialize auth state from local storage
  Future<AuthService> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getInt(_sessionKey);
      if (savedUserId != null) {
        final db = await DatabaseHelper.instance.database;
        final List<Map<String, dynamic>> results = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [savedUserId],
          limit: 1,
        );
        if (results.isNotEmpty) {
          _currentUser.value = UserModel.fromMap(results.first);
        }
      }
    } catch (e) {
      // In case of error reading session, keep user logged out
      _currentUser.value = null;
    }
    return this;
  }

  /// Register a new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final trimmedEmail = email.trim().toLowerCase();

    // Check if email already registered
    final List<Map<String, dynamic>> existing = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [trimmedEmail],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      throw Exception('An account with this email already exists.');
    }

    final passwordHash = hashPassword(password);
    final user = UserModel(
      name: name.trim(),
      email: trimmedEmail,
      passwordHash: passwordHash,
      createdAt: DateTime.now(),
    );

    final id = await db.insert('users', user.toMap());
    final createdUser = user.copyWith(id: id);
    _currentUser.value = createdUser;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, id);

    return createdUser;
  }

  /// Login existing user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final trimmedEmail = email.trim().toLowerCase();
    final passwordHash = hashPassword(password);

    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password_hash = ?',
      whereArgs: [trimmedEmail, passwordHash],
      limit: 1,
    );

    if (results.isEmpty) {
      // Check if email even exists for a more specific helpful message
      final emailCheck = await db.query(
        'users',
        where: 'LOWER(email) = ?',
        whereArgs: [trimmedEmail],
        limit: 1,
      );
      if (emailCheck.isEmpty) {
        throw Exception('No account found with this email.');
      } else {
        throw Exception('Incorrect password. Please try again.');
      }
    }

    final user = UserModel.fromMap(results.first);
    _currentUser.value = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, user.id!);

    return user;
  }

  /// Logout current user and clear local session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser.value = null;
  }
}
