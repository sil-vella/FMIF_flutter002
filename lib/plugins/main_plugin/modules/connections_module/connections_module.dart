import '../../../../core/00_base/module_base.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../tools/logging/logger.dart';

class ConnectionsModule extends ModuleBase {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods
  final String baseUrl;
  final Map<String, String> _customHeaders = {}; // ✅ Store headers

  /// ✅ Constructor - No Singleton, Let ModuleManager Handle Instances
  ConnectionsModule(this.baseUrl) : super('connections_module') {
    _log.info('🔌 ConnectionsModule initialized with baseUrl: $baseUrl');
  }

  /// ✅ Dispose Method - Clear Resources
  @override
  void dispose() {
    _log.info('🗑 Disposing ConnectionsModule resources...');
    _customHeaders.clear();
    _log.info('✅ ConnectionsModule disposed.');
    super.dispose();
  }

  /// ✅ Validates URLs
  void validateUrl(String url) {
    if (!Uri.tryParse(url)!.isAbsolute) {
      throw Exception('❌ Invalid URL: $url');
    }
  }

  /// ✅ Handles GET Requests
  Future<dynamic> sendGetRequest(String route) async {
    final url = Uri.parse('$baseUrl$route');
    validateUrl(url.toString());

    try {
      final response = await http.get(url, headers: {"Content-Type": "application/json", ..._customHeaders});
      _log.info('📡 GET Request: $url | Status: ${response.statusCode}');

      return _processResponse(response);
    } catch (e) {
      return _handleError('GET', url, e);
    }
  }

  /// ✅ Handles POST Requests
  Future<dynamic> sendPostRequest(String route, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$route');
    validateUrl(url.toString());

    try {
      _log.info('📡 Sending POST request to: $url');
      _log.debug('📝 Request Body: ${jsonEncode(data)}');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", ..._customHeaders},
        body: jsonEncode(data),
      );

      return _processResponse(response);
    } catch (e) {
      return _handleError('POST', url, e);
    }
  }

  /// ✅ Flexible Method to Handle Any HTTP Request
  Future<dynamic> sendRequest(String route, {required String method, Map<String, dynamic>? data}) async {
    final url = Uri.parse('$baseUrl$route');
    validateUrl(url.toString());

    try {
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: {"Content-Type": "application/json", ..._customHeaders});
          break;
        case 'POST':
          response = await http.post(url,
              headers: {"Content-Type": "application/json", ..._customHeaders}, body: jsonEncode(data ?? {}));
          break;
        case 'PUT':
          response = await http.put(url,
              headers: {"Content-Type": "application/json", ..._customHeaders}, body: jsonEncode(data ?? {}));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: {"Content-Type": "application/json", ..._customHeaders});
          break;
        default:
          throw Exception('❌ Unsupported HTTP method: $method');
      }

      _log.info('📡 $method Request: $url | Status: ${response.statusCode}');
      return _processResponse(response);
    } catch (e) {
      return _handleError(method, url, e);
    }
  }

  /// ✅ Process Server Response
  dynamic _processResponse(http.Response response) {
    _log.debug('📥 Response Body: ${response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      _log.error('⚠️ Server Error: ${response.statusCode} | Response: ${response.body}');
      return jsonDecode(response.body);
    }
  }

  /// ✅ Handle Errors
  Map<String, dynamic> _handleError(String method, Uri url, Object e) {
    _log.error('❌ $method request failed for $url: $e');
    return {"message": "$method request failed", "error": e.toString()};
  }
}
