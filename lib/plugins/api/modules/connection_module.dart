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
    print('Attempting GET request to: $url');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      // Log response status
      print('GET request to $url returned status code: ${response.statusCode}');

      // Check for a successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response data: $data');
        return data; // Return parsed response
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return jsonDecode(response.body); // Return error message from server
      }
    } catch (e) {
      print("Error during GET request to $url: $e");
      return {"message": "GET request failed"};
    }
  }

  // Method to handle POST requests
  Future<dynamic> sendPostRequest(String route, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$route');
    print('Attempting POST request to: $url with data: $data');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      // Log response status
      print('POST request to $url returned status code: ${response.statusCode}');

      // Check for success (status code 200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');
        return responseData; // Return parsed response
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return jsonDecode(response.body); // Return error message from server
      }
    } catch (e) {
      print("Error during POST request to $url: $e");
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
    print('Attempting $method request to: $url with data: $data');

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
      print('$method request to $url returned status code: ${response.statusCode}');

      // Check for success (status code 200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');
        return responseData; // Return parsed response
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return jsonDecode(response.body); // Return error message from server
      }
    } catch (e) {
      print("Error during $method request to $url: $e");
      return {"message": "$method request failed"};
    }
  }
}
