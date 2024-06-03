import 'dart:convert';
import 'dart:io';
import 'package:drf_client/src/public/drf_config.dart';
import 'package:drf_client/src/public/drf_response.dart';
import 'package:drf_client/src/auth/oauth_toolkit.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

class OauthToolkitRequest {
  final DrfConfig config;
  final String prefsKey;

  OauthToolkitRequest(this.config, this.prefsKey);

  Future<oauth2.Client?> _initializeClient() async {
    final credentials = await OauthToolkitAuth().getCredentials(prefsKey);
    if (credentials != null) {
      return oauth2.Client(credentials,
          identifier: config.oauthConfig!.clientId,
          secret: config.oauthConfig!.clientSecret);
    }
    throw Exception("Not logged in or invalid Oauth credentials");
  }

  String _makeUrl(String path) {
    String baseUrl =
        config.baseUrl.endsWith('/') ? config.baseUrl : '${config.baseUrl}/';
    String formattedPath = path.startsWith('/') ? path.substring(1) : path;
    formattedPath = (formattedPath.endsWith('/') || formattedPath.contains('?'))
        ? formattedPath
        : '$formattedPath/';
    return '$baseUrl$formattedPath';
  }

  Future<DrfResponse> _performRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final client = (await _initializeClient())!;

      final url = _makeUrl(path);
      final uri = Uri.parse(url);
      http.Response response;

      // Prepare headers, merging custom headers if provided
      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (customHeaders != null) {
        headers.addAll(customHeaders);
      }

      switch (method.toUpperCase()) {
        case 'GET':
          response = await client.get(uri, headers: headers);
          break;
        case 'POST':
          response =
              await client.post(uri, headers: headers, body: json.encode(body));
          break;
        case 'PUT':
          response =
              await client.put(uri, headers: headers, body: json.encode(body));
          break;
        case 'PATCH':
          response = await client.patch(uri,
              headers: headers, body: json.encode(body));
          break;
        case 'DELETE':
          response = await client.delete(uri, headers: headers);
          break;
        default:
          throw Exception("This http method not supported");
      }

      return DrfResponse.put(
          statusCode: response.statusCode,
          body: response.body.isNotEmpty ? json.decode(response.body) : {},
          httpResponse: response);
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  // Public methods to perform specific requests, including custom headers parameter
  Future<DrfResponse> get(String path, {Map<String, String>? headers}) =>
      _performRequest(method: 'GET', path: path, customHeaders: headers);
  Future<DrfResponse> post(String path, Map<String, dynamic> body,
          {Map<String, String>? headers, Map<String, File>? files}) =>
      _performRequest(
          method: 'POST', path: path, body: body, customHeaders: headers);
  Future<DrfResponse> put(String path, Map<String, dynamic> body,
          {Map<String, String>? headers, Map<String, File>? files}) =>
      _performRequest(
          method: 'PUT', path: path, body: body, customHeaders: headers);
  Future<DrfResponse> patch(String path, Map<String, dynamic> body,
          {Map<String, String>? headers, Map<String, File>? files}) =>
      _performRequest(
          method: 'PATCH', path: path, body: body, customHeaders: headers);
  Future<DrfResponse> delete(String path, {Map<String, String>? headers}) =>
      _performRequest(method: 'DELETE', path: path, customHeaders: headers);
}
