import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, or your local IP for physical devices
  static const String baseUrl = 'http://192.168.1.66:5000/api';

  Future<Map<String, dynamic>> selectDataset(String id) async {
    final uri = Uri.parse('$baseUrl/select_dataset');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to select dataset');
    }
  }

  Future<Map<String, dynamic>> uploadFile(File file) async {
    final uri = Uri.parse('$baseUrl/upload');
    final request = http.MultipartRequest('POST', uri);
    
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('text', 'csv'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Upload failed with status: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getElbowData() async {
    final uri = Uri.parse('$baseUrl/elbow');
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load elbow data');
    }
  }

  Future<Map<String, dynamic>> getClusterData(int k, {String vizMode = 'Income vs Score'}) async {
    final uri = Uri.parse('$baseUrl/cluster');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'k': k, 'viz_mode': vizMode}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cluster data');
    }
  }

  Future<Map<String, dynamic>> predictCluster({
    required double age,
    required double income,
    required double spending,
  }) async {
    final uri = Uri.parse('$baseUrl/predict');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'age': age,
        'income': income,
        'spending': spending,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to predict cluster');
    }
  }
}
