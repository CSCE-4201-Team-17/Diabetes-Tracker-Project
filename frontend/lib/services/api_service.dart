import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/glucose_reading.dart';
import '../models/user.dart';
import '../models/meal_record.dart';
import 'storage_service.dart';
import '../models/medication.dart'; 
import '../widgets/glucose_chart.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5001/api';
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
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authToken = data['token'];
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
    final userId = StorageService.userId;

    final body = reading.toJson();
    body['userId'] = userId;

    final response = await http.post(
      Uri.parse('$baseUrl/glucose'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );

    return response.statusCode == 201;
  }

  //AI Chat
  static Future<String> sendChatMessage(
    String message, {
    required List<BloodSugarReading> readings,
    required List<Medication> medications,
  }) async {
    final userId = StorageService.userId;

    final readingsJson = readings.map((r) {
      return {
        'value': r.value,
        'timestamp': r.timestamp.toIso8601String(),
        'type': r.type,
      };
    }).toList();

    final medsJson = medications.map((m) {
      return {
        'name': m.name,
        'dosage': m.dosage,
        'hour': m.hour,
        'minute': m.minute,
        'taken': m.taken,
      };
    }).toList();

    final response = await http.post(
      Uri.parse('$baseUrl/ai/chat'),
      headers: await _getHeaders(),
      body: json.encode({
        'userId': userId,
        'message': message,
        'readings': readingsJson,
        'medications': medsJson,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['reply'];
    } else {
      throw Exception("AI assistant failed");
    }
  }

  //Glucose Prediction
  static Future<Map<String, dynamic>> predictGlucose(
    List<BloodSugarReading> readings, {
    int hoursAhead = 2,
  }) async {
    final body = {
      'hoursAhead': hoursAhead,
      'readings': readings.map((r) => {
        'value': r.value,
        'timestamp': r.timestamp.toIso8601String(),
        'type': r.type,
      }).toList(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/glucose/predict'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Prediction failed");
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

  //Meal Upload Methods
  static Future<Map<String, dynamic>> uploadMealImage(File imageFile) async {
    try {
      final userId = StorageService.userId;
      if (userId == null) {
        throw Exception('User ID not found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_meal'),
      );

      //Adds image file
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      //Adds userId as form data
      request.fields['userId'] = userId;

      //Adds headers if needed
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to upload image: ${json.decode(responseData)['error']}');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  static Future<bool> saveMealRecord(MealRecord mealRecord) async {
    try {
      //Note: I might need to change this endpoint since it might not exist yet in our backend, but keeping it for future use
      final response = await http.post(
        Uri.parse('$baseUrl/meals'),
        headers: await _getHeaders(),
        body: json.encode(mealRecord.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving meal record: $e');
      return false;
    }
  }

  static Future<List<MealRecord>> getUserMeals(String userId) async {
    try {
      //Note: I might need to change this endpoint since it might not exist yet in our backend, but keeping it for future use
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/meals'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MealRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching meals: $e');
      return [];
    }
  }
}