import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/glucose_reading.dart';
import '../models/user.dart';
import '../models/meal_record.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://your-backend-url:5000/api';
  static String? _authToken;
  
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  //Authentication
  static Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'), //Actual backend endpoint
      headers: await _getHeaders(),
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _authToken = data['token'];
      //Store token for future requests
      await StorageService.setAuthToken(data['token']);
      await StorageService.setUserId(data['user']['id']);
      return {'success': true, 'user': data['user']};
    } else {
      return {'success': false, 'error': 'Invalid credentials'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Network error: $e'};
  }
}

  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _authToken = data['token'];
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  //Glucose Readings
  static Future<List<BloodSugarReading>> getGlucoseReadings(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/glucose'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BloodSugarReading.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    print('Error fetching glucose readings: $e');
    return [];
  }
}
  
  static Future<bool> addGlucoseReading(BloodSugarReading reading) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/glucose'),
        headers: await _getHeaders(),
        body: json.encode(reading.toJson()),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding glucose reading: $e');
      return false;
    }
  }
  
  //Meal Analysis
  static Future<Map<String, dynamic>> analyzeMeal(String imageUrl, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-meal'),
        headers: await _getHeaders(),
        body: json.encode({
          'imageUrl': imageUrl,
          'description': description,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'error': 'Failed to analyze meal'};
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }
  
  //Get weekly summary
  static Future<Map<String, dynamic>> getWeeklySummary(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/weekly-summary'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching weekly summary: $e');
      return {};
    }
  }

  //Get user profile
  static Future<User?> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
}