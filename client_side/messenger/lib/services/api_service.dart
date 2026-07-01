import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String _baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3000/api'
      : 'http://localhost:3000/api';

  ApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 20);
    _dio.options.receiveTimeout = const Duration(seconds: 20);

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: "token");

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          print("API Error: ${error.response?.data}");
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data["token"];
      final userId = response.data["_id"];

      if (token != null) {
        await _storage.write(key: "token", value: token);
        await _storage.write(key: "userId", value: userId);
      }

      final savedToken = await _storage.read(key: "token");
      debugPrint("Saved Token: $savedToken");
      debugPrint("Login Response: ${response.data}");
      return response.data;
    } on DioException {
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return response.data;
    } on DioException {
      throw Exception('Failed to fetch profile');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: "token");
    print("🔍 Stored token: $token");

    if (token == null || token.isEmpty) return false;

    try {
      await getProfile();
      print("✅ Token is valid");
      return true;
    } catch (e) {
      print("❌ Token validation failed: $e");
      return false;
    }
  }

  Future<String?> getMyUserId() async {
    return await _storage.read(key: "userId");
  }

  Future<List<dynamic>> getContacts() async {
    final response = await _dio.get("/contacts");
    return response.data;
  }

  Future<void> addContact(String email) async {
    try {
      await _dio.post("/contacts/add", data: {"email": email});
    } on DioException catch (e) {
      final message = e.response?.data["message"] ?? "Something went wrong";
      throw Exception(message);
    }
  }

  Future<List<dynamic>> getMessages(String userId) async {
    final response = await _dio.get("/messages/$userId");
    return response.data;
  }

  Future<void> sendMessage(String receiverId, String text) async {
    await _dio.post(
      "/messages",
      data: {"receiverId": receiverId, "text": text},
    );
  }

  Future<void> markMessagesAsSeen(String userId) async {
    try {
      await _dio.put("/messages/seen/$userId");
    } catch (e) {
      print("SEEN ERROR:");
      print(e);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: "token");
  }
}
