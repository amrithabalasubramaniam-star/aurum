import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

class Api {
  Api._();
  static final Api instance = Api._();
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? userName;

  /// Called when the server says the token is no longer valid.
  void Function()? onUnauthorized;

  Future<bool> loadSession() async {
    _token = await _storage.read(key: 'token');
    userName = await _storage.read(key: 'name');
    return _token != null;
  }

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, String>? q]) =>
      Uri.parse('$kBaseUrl/api/v1/$path').replace(queryParameters: q?..removeWhere((k, v) => v.isEmpty));

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    http.Response res;
    try {
      res = await call().timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ApiException('Cannot reach the server. Check your connection and server address.');
    }
    dynamic body;
    try {
      body = res.body.isEmpty ? {} : jsonDecode(res.body);
    } catch (_) {
      body = {};
    }
    if (res.statusCode == 401) {
      onUnauthorized?.call();
      throw ApiException('Session expired. Please sign in again.', 401);
    }
    if (res.statusCode >= 400) {
      String msg = (body is Map && body['message'] is String) ? body['message'] : 'Request failed (${res.statusCode}).';
      if (body is Map && body['errors'] is Map && (body['errors'] as Map).isNotEmpty) {
        msg = ((body['errors'] as Map).values.first as List).first.toString();
      }
      throw ApiException(msg, res.statusCode);
    }
    return body;
  }

  Future<void> login(String email, String password) async {
    final body = await _send(() => http.post(_uri('login'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password})));
    _token = body['token'];
    userName = body['name'];
    await _storage.write(key: 'token', value: _token);
    await _storage.write(key: 'name', value: userName);
  }

  Future<void> logout() async {
    try {
      await _send(() => http.post(_uri('logout'), headers: _headers));
    } catch (_) {}
    _token = null;
    await _storage.deleteAll();
  }

  Future<Map<String, dynamic>> dashboard() async =>
      Map<String, dynamic>.from(await _send(() => http.get(_uri('dashboard'), headers: _headers)));

  Future<Map<String, dynamic>> reservations({String q = '', String status = '', String date = '', int page = 1}) async =>
      Map<String, dynamic>.from(await _send(() => http.get(
          _uri('reservations', {'q': q, 'status': status, 'date': date, 'page': '$page'}),
          headers: _headers)));

  Future<Map<String, dynamic>> setStatus(int id, String status) async =>
      Map<String, dynamic>.from(await _send(() => http.patch(_uri('reservations/$id/status'),
          headers: _headers, body: jsonEncode({'status': status}))));

  Future<Map<String, dynamic>> customers({String q = '', bool vip = false, int page = 1}) async =>
      Map<String, dynamic>.from(await _send(() => http.get(
          _uri('customers', {'q': q, 'vip': vip ? '1' : '', 'page': '$page'}),
          headers: _headers)));

  Future<Map<String, dynamic>> customer(int id) async =>
      Map<String, dynamic>.from(await _send(() => http.get(_uri('customers/$id'), headers: _headers)));
}
