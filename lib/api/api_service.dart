import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ======================
  // Base URL (Android Emulator)
  // ======================
  static const String _baseUrl = 'http://10.0.2.2:8000';

  // ======================
  // API Paths
  // ======================
  static const String authBaseUrl = '$_baseUrl/api/auth';
  static const String caseBaseUrl = '$_baseUrl/api/cases';

  // ======================
  // Helpers
  // ======================

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print("TOKEN => $token");
    return token;
  }

  static Map<String, String> _jsonHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static void _ensureJson(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';

    print("STATUS CODE => ${response.statusCode}");
    print("RESPONSE BODY => ${response.body}");

    if (!contentType.contains('application/json')) {
      throw Exception(
        'السيرفر رجّع HTML — غالبًا رابط API غلط أو التوكن ما وصل',
      );
    }
  }

  // ======================
  // تسجيل الدخول
  // ======================

  static Future<Map<String, dynamic>> login({
    required String nationalId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$authBaseUrl/login/'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'national_id': nationalId.trim(),
        'password': password,
      }),
    );

    _ensureJson(response);
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', decoded['data']['access']);

      print("TOKEN SAVED => ${decoded['data']['access']}");
      return decoded;
    }

    throw Exception(decoded['message'] ?? 'فشل تسجيل الدخول');
  }

  // ======================
  // تسجيل حساب
  // ======================

  static Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String nationalId,
    required String password,
    required bool isHealthPractitioner,
    required int organizationId,
  }) async {
    final response = await http.post(
      Uri.parse('$authBaseUrl/register/'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'full_name': fullName.trim(),
        'email': email.trim(),
        'phone_number': phone.trim(),
        'national_id': nationalId.trim(),
        'password': password,
        'is_health_practitioner': isHealthPractitioner,
        'organization': organizationId,
      }),
    );

    _ensureJson(response);

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'فشل إنشاء الحساب');
    }
  }

  // ======================
  // الجهات
  // ======================

  static Future<List<Map<String, dynamic>>> fetchOrganizations() async {
    final response = await http.get(
      Uri.parse('$authBaseUrl/organizations/'),
      headers: _jsonHeaders(),
    );

    _ensureJson(response);

    if (response.statusCode != 200) {
      throw Exception('فشل جلب الجهات');
    }

    return List<Map<String, dynamic>>.from(
      jsonDecode(response.body),
    );
  }

  // ======================
  // إنشاء حالة
  // ======================

  static Future<void> createCaseReport({
    required Map<String, dynamic> payload,
  }) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('المستخدم غير مسجل دخول');
    }

    final response = await http.post(
      Uri.parse('$caseBaseUrl/create/'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode(payload),
    );

    _ensureJson(response);

    if (response.statusCode != 201) {
      throw Exception('فشل إرسال الحالة');
    }
  }

  // ======================
  // Dashboard
  // ======================

  static Future<Map<String, dynamic>> fetchDashboardStats() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$caseBaseUrl/dashboard/'),
      headers: _jsonHeaders(token: token),
    );

    _ensureJson(response);

    if (response.statusCode != 200) {
      throw Exception("Dashboard Error");
    }

    final decoded = jsonDecode(response.body);
    final data = decoded['data'] ?? decoded;

    return {
      "active_responders": data['active_responders'] ?? 0,
      "total_cases": data['total_cases'] ?? 0,
      "my_responded_cases": data['my_responded_cases'] ?? 0,
      "services_stats": data['services_stats'] ?? {},
    };
  }

  // ======================
  // PROFILE API
  // ======================

  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception("لا يوجد توكن — سجل دخول أول");
    }

    final response = await http.get(
      Uri.parse('$authBaseUrl/profile/'),
      headers: _jsonHeaders(token: token),
    );

    _ensureJson(response);

    if (response.statusCode != 200) {
      throw Exception("فشل تحميل بيانات المستخدم");
    }

    return jsonDecode(response.body);
  }

  static Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$authBaseUrl/profile/'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({
        "full_name": fullName,
        "email": email,
        // 👇 التعديل المهم
        "phone_number": phone,
      }),
    );

    _ensureJson(response);

    if (response.statusCode != 200) {
      throw Exception("فشل تحديث البيانات");
    }
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$authBaseUrl/change-password/'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({
        "old_password": oldPassword,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      }),
    );

    _ensureJson(response);

    if (response.statusCode != 200) {
      throw Exception("فشل تغيير كلمة المرور");
    }
  }

  // ======================
  // تسجيل خروج
  // ======================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
