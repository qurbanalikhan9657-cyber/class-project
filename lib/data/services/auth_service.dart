import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
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
  static const String _webUsersKey = 'web_registered_users';
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
        if (kIsWeb) {
          final users = _getWebUsers(prefs);
          final user = users.firstWhereOrNull((u) => u.id == savedUserId);
          if (user != null) {
            _currentUser.value = user;
          }
        } else {
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
      }
    } catch (e) {
      _currentUser.value = null;
    }
    return this;
  }

  /// Helper to get users from SharedPreferences on Web
  List<UserModel> _getWebUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_webUsersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => UserModel.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  /// Helper to save users to SharedPreferences on Web
  Future<void> _saveWebUsers(SharedPreferences prefs, List<UserModel> users) async {
    final list = users.map((u) => u.toMap()).toList();
    await prefs.setString(_webUsersKey, jsonEncode(list));
  }

  /// Register a new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final passwordHash = hashPassword(password);
    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      final users = _getWebUsers(prefs);
      final exists = users.any((u) => u.email.toLowerCase() == trimmedEmail);
      if (exists) {
        throw Exception('An account with this email already exists.');
      }

      int maxId = 0;
      for (final u in users) {
        if (u.id != null && u.id! > maxId) maxId = u.id!;
      }
      final nextId = maxId + 1;

      final newUser = UserModel(
        id: nextId,
        name: name.trim(),
        email: trimmedEmail,
        passwordHash: passwordHash,
        createdAt: DateTime.now(),
      );

      users.add(newUser);
      await _saveWebUsers(prefs, users);
      await prefs.setInt(_sessionKey, nextId);
      _currentUser.value = newUser;
      return newUser;
    } else {
      final db = await DatabaseHelper.instance.database;

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

      final user = UserModel(
        name: name.trim(),
        email: trimmedEmail,
        passwordHash: passwordHash,
        createdAt: DateTime.now(),
      );

      final id = await db.insert('users', user.toMap());
      final createdUser = user.copyWith(id: id);
      _currentUser.value = createdUser;

      await prefs.setInt(_sessionKey, id);
      return createdUser;
    }
  }

  /// Login existing user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final passwordHash = hashPassword(password);
    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      final users = _getWebUsers(prefs);
      final user = users.firstWhereOrNull(
        (u) => u.email.toLowerCase() == trimmedEmail && u.passwordHash == passwordHash,
      );

      if (user == null) {
        final emailExists = users.any((u) => u.email.toLowerCase() == trimmedEmail);
        if (!emailExists) {
          throw Exception('No account found with this email.');
        } else {
          throw Exception('Incorrect password. Please try again.');
        }
      }

      await prefs.setInt(_sessionKey, user.id!);
      _currentUser.value = user;
      return user;
    } else {
      final db = await DatabaseHelper.instance.database;

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

      await prefs.setInt(_sessionKey, user.id!);
      return user;
    }
  }

  /// Logout current user and clear local session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser.value = null;
  }
}
