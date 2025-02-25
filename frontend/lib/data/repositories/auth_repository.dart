import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:frontend/core/config/api_config.dart';

class AuthRepository {
  final logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String baseUserUrl = ApiConfig.baseUserUrl;
  final _storage = FlutterSecureStorage();

  //* Signup
  Future<User> signup({
    required String email,
    required String password,
    required String displayName,
    required List<String> genres,
    required List<String> themes,
  }) async {
    try {
      debugPrint("🔄 Signing up user: $email");
      logger.d("Signup process started for $email");

      //* Firebase Signup
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = userCredential.user!;

      //* Update display name
      await user.updateDisplayName(displayName);
      debugPrint("Display name updated: $displayName");

      //* Fetch ID Token
      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception("Failed to retrieve ID token");
      }
      debugPrint("🔑 ID Token retrieved successfully");

      //* Send additional user data to backend
      final url = Uri.parse('$baseUserUrl/auth/signup');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          "email": email,
          "displayName": displayName,
          "preferences": {
            "genre": genres,
            "theme": themes,
          },
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final backendMessage = jsonDecode(response.body)['message'];
        throw Exception(backendMessage ?? 'Unexpected error during signup.');
      }

      //* Store ID Token securely
      await _storage.write(key: 'idToken', value: idToken);
      debugPrint("ID Token stored successfully");

      return user; // Return the created user
    } catch (e) {
      debugPrint("Signup failed: ${e.toString()}");
      throw Exception("Signup failed: ${e.toString()}");
    }
  }

  //* Login
  Future<User> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    try {
      debugPrint("🔄 Logging in user: $email");

      final url = Uri.parse('$baseUserUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "fcmToken": fcmToken,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
      }

      final customToken = jsonDecode(response.body)['customToken'];

      //* Sign in with Firebase custom token
      UserCredential userCredential =
          await _auth.signInWithCustomToken(customToken);
      User user = userCredential.user!;

      //* Retrieve ID token
      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve ID Token.');
      }

      //* Store ID token securely
      await _storage.write(key: 'idToken', value: idToken);
      debugPrint("Login successful for ${user.email}");

      return user; // Return the logged-in user
    } catch (e) {
      debugPrint("Login failed: ${e.toString()}");
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  //* Retrieve ID token
  Future<String?> getIdToken() async {
    return await _storage.read(key: 'idToken');
  }

  //* Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _storage.delete(key: 'idToken');
    debugPrint("User logged out successfully");
  }

  //* Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent to $email");
    } catch (e) {
      throw Exception("Failed to reset password: ${e.toString()}");
    }
  }
}
