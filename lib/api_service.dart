import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Dynamically determine the base URL
  static String get baseUrl {
    // Check if a backend URL is provided via --dart-define=BACKEND_URL=...
    const prodUrl = String.fromEnvironment('BACKEND_URL');
    if (prodUrl.isNotEmpty) return '$prodUrl/api';

    // PRIORITIZE LIVE BACKEND FOR TESTING
    return 'https://benevolent-froyo-3489b0.netlify.app/api';

    /* Local fallback (uncomment if needed)
    if (kIsWeb) return 'http://localhost:3001/api';
    return 'http://10.0.2.2:3001/api';
    */
  }
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // --- Auth ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
    );
    return jsonDecode(response.body);
  }

  // --- Services ---
  Future<List<Service>> getServices() async {
    final response = await http.get(Uri.parse('$baseUrl/services'), headers: _headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Service.fromJson(json)).toList();
    }
    return [];
  }

  Future<Service?> createService(Map<String, dynamic> serviceData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/services'),
      headers: _headers,
      body: jsonEncode(serviceData),
    );
    if (response.statusCode == 200) {
      return Service.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Service?> updateService(String id, Map<String, dynamic> serviceData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/services/$id'),
        headers: _headers,
        body: jsonEncode(serviceData),
      );
      debugPrint('Update Service Status: ${response.statusCode}');
      debugPrint('Update Service Body: ${response.body}');
      if (response.statusCode == 200) {
        return Service.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Update Service Error: $e');
    }
    return null;
  }

  Future<bool> deleteService(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/services/$id'),
      headers: _headers,
    );
    return response.statusCode == 204;
  }

  // --- Bookings ---
  Future<List<Booking>> getBookings() async {
    final response = await http.get(Uri.parse('$baseUrl/bookings'), headers: _headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Booking.fromJson(json)).toList();
    }
    return [];
  }

  Future<Booking?> createBooking(String serviceId, String date, String time) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _headers,
      body: jsonEncode({'serviceId': serviceId, 'date': date, 'time': time}),
    );
    if (response.statusCode == 200) {
      return Booking.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Booking?> updateBooking(String id, Map<String, dynamic> updateData) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/bookings/$id'),
      headers: _headers,
      body: jsonEncode(updateData),
    );
    if (response.statusCode == 200) {
      return Booking.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}
