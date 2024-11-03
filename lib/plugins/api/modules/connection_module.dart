import 'package:http/http.dart' as http;
import 'dart:convert';

class ConnectionModule {
  final String baseUrl;

  ConnectionModule._internal(this.baseUrl);

  /// Factory method to create an instance with the specified baseUrl
  factory ConnectionModule(String baseUrl) {
    return ConnectionModule._internal(baseUrl);
  }

  // Method to handle GET requests
  Future<dynamic> sendGetRequest(String route) async {
    final url = Uri.parse('$baseUrl$route');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return parsed response
      } else {
        print("Error response: ${response.body}");
        return jsonDecode(response.body); // Return error message from server
      }
    } catch (e) {
      print("Error: $e");
      return {"message": "Request failed"};
    }
  }

  // Method to handle POST requests
  Future<dynamic> sendPostRequest(String route, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$route');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // Return parsed response
      } else {
        print("Error response: ${response.body}");
        return jsonDecode(response.body); // Return error message from server
      }
    } catch (e) {
      print("Error: $e");
      return {"message": "Request failed"};
    }
  }

  // Flexible method that accepts both GET and POST requests based on the request type
  Future<dynamic> sendRequest(
      String route, {
        String method = 'POST',
        Map<String, dynamic>? data,
      }) async {
    final url = Uri.parse('$baseUrl$route');
    try {
      http.Response response;

      if (method == 'GET') {
        response = await http.get(
          url,
          headers: {"Content-Type": "application/json"},
        );
      } else {
        response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data ?? {}),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // Return parsed response
      } else {
        print("Error response: ${response.body}");
        return jsonDecode(response.body); // Return error message from server
      }
    } catch (e) {
      print("Error: $e");
      return {"message": "Request failed"};
    }
  }
}
