import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // Obtenir les headers avec le token JWT
  static Future<Map<String, String>> _getHeaders([Map<String, String>? customHeaders]) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    final token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    
    return headers;
  }

  // Wrapper pour http.get
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final authHeaders = await _getHeaders(headers);
    final response = await http.get(url, headers: authHeaders);
    _handleAuthErrors(response);
    return response;
  }

  // Wrapper pour http.post
  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final authHeaders = await _getHeaders(headers);
    final jsonBody = (body is Map || body is List) ? json.encode(body) : body;
    final response = await http.post(url, headers: authHeaders, body: jsonBody, encoding: encoding);
    _handleAuthErrors(response);
    return response;
  }

  // Wrapper pour http.put
  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final authHeaders = await _getHeaders(headers);
    final jsonBody = (body is Map || body is List) ? json.encode(body) : body;
    final response = await http.put(url, headers: authHeaders, body: jsonBody, encoding: encoding);
    _handleAuthErrors(response);
    return response;
  }

  // Wrapper pour http.delete
  static Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final authHeaders = await _getHeaders(headers);
    final jsonBody = (body is Map || body is List) ? json.encode(body) : body;
    final response = await http.delete(url, headers: authHeaders, body: jsonBody, encoding: encoding);
    _handleAuthErrors(response);
    return response;
  }

  // Ne déconnecter que sur 401 (session expirée). Un 403 peut être une règle métier (ex. mauvais id URL) — ne pas effacer le token.
  static void _handleAuthErrors(http.Response response) {
    if (response.statusCode == 401) {
      AuthService.logout();
    }
  }
}
