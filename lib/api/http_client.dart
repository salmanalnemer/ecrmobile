import 'package:http/http.dart' as http;
import '../core/secure_storage.dart';

class HttpClient {
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// تجهيز Headers مع JWT تلقائيًا
  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getAccessToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// GET
  static Future<http.Response> get(String path) async {
    final headers = await _headers();
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  /// POST
  static Future<http.Response> post(String path, {String? body}) async {
    final headers = await _headers();
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body,
    );
  }

  /// PUT
  static Future<http.Response> put(String path, {String? body}) async {
    final headers = await _headers();
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body,
    );
  }

  /// DELETE
  static Future<http.Response> delete(String path) async {
    final headers = await _headers();
    return http.delete(Uri.parse('$baseUrl$path'), headers: headers);
  }
}
