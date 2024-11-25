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

      // Log response status

      // Check for a successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Return parsed response
      } else {
        return jsonDecode(response.body); // Return error message from server
      }
    } catch (e) {
      return {"message": "GET request failed"};
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

      // Log response status

      // Check for success (status code 200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData; // Return parsed response
      } else {
        return jsonDecode(response.body); // Return error message from server
      }
    } catch (e) {
      return {"message": "POST request failed"};
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

      // Log response status

      // Check for success (status code 200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData; // Return parsed response
      } else {
        return jsonDecode(response.body); // Return error message from server
      }
    } catch (e) {
      return {"message": "$method request failed"};
    }
  }
}
